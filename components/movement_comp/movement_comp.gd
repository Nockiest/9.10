class_name MovementComponent
extends Node2D
signal remain_movement_changed( )
signal ran_out_of_movement()
const base_movement_points:int = 1
var base_movement_range:int:
	set(new_range):
		base_movement_range = new_range
		remain_distance = base_movement_range 
@onready var global_start_turn_position :Vector2 =   global_position 
@onready var buy_areas = get_tree().get_nodes_in_group("buy_areas")

var remain_distance  = base_movement_range:
	set(new_distance):
		remain_distance =new_distance 
		emit_signal("remain_movement_changed"  )
		if new_distance < 0 :
			print("ABORTING MOVEMENT")
			abort_movement()
			emit_signal("ran_out_of_movement") 
	get:
		return remain_distance
var movement_modifiers:Dictionary = {
	"base_modifier": 1,
	"on_road": 0,
	"in_forrest": 0,
}#A SET FUNCTION DOESNT WORK ON DICTIONARIES:
#	set(new_value):
#		print("SETTING", new_value)
#		movement_modifiers = new_value 
#		calculate_total_movement_modifier()
#	get:
#		return movement_modifiers
var current_movement_modifier =  calculate_total_movement_modifier()
var on_bridge:bool = false 
var on_river:bool= false
var last_position:Vector2
var mouse_pos_offset: Vector2= Vector2(0,0)
enum state {
	Idle,
	Moving,
	Placed
}
var current_state:state = state.Idle
 
func _ready():
	call_deferred_thread_group("calculate_total_movement_modifier")
	last_position = owner.position
	
func enter_movement_state():
	if not check_can_turn_movement_on():
		exit_movement_state() 
		return 
#	Input.set_mouse_position(owner.center)
	Globals.moving_unit = owner
	Globals.action_taking_unit = null
	print("TURNING MOVEMENT LOOK ON")
	var mouse_pos = get_global_mouse_position()
	var x_distance = mouse_pos.x - global_position.x
	var y_distance = mouse_pos.y - global_position.y
	mouse_pos_offset = Vector2(x_distance, y_distance)#global_position.distance_to(get_global_mouse_position())
	print("MOUSE OFFSET ", mouse_pos_offset)
	toggle_moving_appearance("on")
	current_state = state.Moving

func exit_movement_state():
	current_state = state.Idle
	toggle_moving_appearance("off")
	if Globals.moving_unit == owner:
		Globals.moving_unit = null

func exit_placed_state():
	print("EXITING PLAED STATE")
	current_state = state.Idle
#	owner.global_position = global_start_turn_position#Vector2(global_start_turn_position.x + mouse_pos_offset.x, global_start_turn_position.y + mouse_pos_offset.y) 
func enter_placed_state():
	current_state = state.Placed

func toggle_moving_appearance(toggle):
	if toggle == "on":
		print("TURNING MOVING APPEARANCE ON")
		owner.outline_node.modulate = Color("black")
		owner.get_node("ColorRect").modulate = Color("gray")
	elif toggle == "off":
		owner.outline_node.modulate = Color("white")
		owner.get_node("ColorRect").modulate = Color(owner.color)
	else:
		print("ARGUMENT ", toggle)
		assert(false, "TOGGLE MOVEMENT COLOR GOT BAD ARGUMENT" )


func calculate_total_movement_modifier():
	current_movement_modifier = Utils.sum_dict_values(movement_modifiers)
#	print("RECALCULATING MOVEMENT MODIFIERS")

func process(_delta):
	if current_state == state.Placed: 
		owner.position = get_global_mouse_position() - owner.size / 2
		if Input.is_action_just_pressed("left_click"):
			process_unit_placement()
	elif current_state == state.Moving:
		call_deferred_thread_group("move", owner.size)# move(owner.size)
		if Input.is_action_just_pressed("right_click"):
			abort_movement()
		elif Input.is_action_just_pressed("left_click"):
#			set_new_start_turn_point()
			exit_movement_state()
	elif current_state == state.Idle:
		if Input.is_action_just_pressed("left_click"):
			enter_movement_state()

func process_unit_placement():
	if Globals.hovered_unit != null and Globals.hovered_unit != owner:
		print(Globals.hovered_unit == null, Globals.hovered_unit, "POSITION CANNOT BE SET")
		return
	var in_valid_buy_area = false
	## check wheter it is being placed inside the buy bar
	for buy_area in buy_areas:
#			print("COLORS",Color(buy_area.team) , color, buy_area.units_inside)
		if Color(buy_area.team) != owner.color:
			continue  
		if owner not in buy_area.units_inside:
			continue
		print("IN BUY AREA")
		in_valid_buy_area = true
	## check wheter it is placed in and of the occupied cities
	for town in get_tree().get_nodes_in_group("towns"):
		if town.team_alligiance == null:
			continue
		if Color(town.team_alligiance)!= owner.color:
			continue
		if self in town.units_inside:
			print("UNIT IS INSIDE OF AN OCCUPIED CITY")
			in_valid_buy_area = true
	
	for river_segment in get_tree().get_nodes_in_group("river_segments"):
#			print(river_segment.get_node("Area2D"), river_segment.get_node("Area2D").get_overlapping_areas ( ))
		for area in  river_segment.get_node("Area2D").get_overlapping_areas ( ):
			if area == owner.get_node("CollisionArea"):
				print(area, " OVERLAPS")
				in_valid_buy_area = false
				break

	if in_valid_buy_area:
		print(Globals.hovered_unit,"CAN PLACE A UNIT")
		owner.is_newly_bought = false
		Globals.placed_unit = null
		exit_placed_state()
		return
	print(Globals.hovered_unit, in_valid_buy_area, "POSITION CANNOT BE SET")
 

	if Input.is_action_just_pressed("right_click"): 
		print("ABORTING BUYING AND GIVING MONEY BACK")
		queue_free()

func check_can_turn_movement_on():
	if Globals.hovered_unit != get_parent():
		print("CASE 2")
		return false
	elif Globals.action_taking_unit != get_parent() and Globals.action_taking_unit != null:
		print("CASE 3")
		return false
	elif Globals.action_taking_unit != null:
		print("CASE 4")
		return false
	elif Globals.placed_unit != null:
		print("case 5")
		return false
	return true


func move(size_of_scene):
	if Globals.moving_unit != owner:
		return
	if on_river and not on_bridge and movement_modifiers["on_road"] == 0:
		abort_movement()
	var mouse_pos = get_global_mouse_position() 
	var new_position = global_position
	var distance_just_traveled = 0  #last_position.distance_to(mouse_pos )#0
	var distance_with_offset =global_position - mouse_pos_offset
	new_position = mouse_pos - size_of_scene / 2  - mouse_pos_offset #mouse_pos - mouse_pos_offset#mouse_pos - size_of_scene / 2
	if floor( global_position.distance_to(mouse_pos) ) <= 1 :
		distance_just_traveled =  0
	else:
		distance_just_traveled = floor( distance_with_offset.distance_to(mouse_pos) ) * current_movement_modifier  
#	remain_distance -= distance_just_traveled
	owner.position=  new_position # Vector2(new_position.x - mouse_pos_offset.x, new_position.y - mouse_pos_offset.y) 


func abort_movement():
	print("CALLED ABORT MOVEMENT ", global_start_turn_position)
	Globals.moving_unit = null
	remain_distance = base_movement_range
	owner.position = global_start_turn_position
	call_deferred_thread_group("exit_movement_state")
 

func process_for_next_turn():
#	remain_movement =  base_movement_points
	remain_distance = base_movement_range
	set_new_start_turn_point()  
#	owner.position = global_start_turn_position


func  set_new_start_turn_point():
	print("SETTING NEW START TURN POS",global_position)
	global_start_turn_position = global_position
