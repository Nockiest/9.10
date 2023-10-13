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
var remain_movement:int = base_movement_points:
	set(new_movement):
		print("NEW MOVEMENT ", new_movement)
		remain_movement = new_movement
#		exit_movement_state()
		emit_signal("remain_movement_changed"  )
	get:
		return remain_movement
var movement_modifieres:Dictionary = {
	"base_modifier": 1,
	"on_road": 0,
	"in_forrest": 0
}:
	set(new_value):
		print("SETTING", new_value)
		movement_modifieres = new_value 
		calculate_total_movement_modifier()
	get:
		return movement_modifieres
var current_movement_modifier = Utils.sum_dict_values(movement_modifieres)
var on_bridge:bool = false 
var on_river:bool= false
var last_position:Vector2
var mouse_pos_offset 
enum state {
	Idle,
	Moving
}
var current_state = state.Idle
 
func _ready():
	call_deferred_thread_group("calculate_total_movement_modifier")
	last_position = owner.position
	
func enter_movement_state():
	print("ENTEREING MOVEMENT STATE")
	Globals.moving_unit = owner
	Globals.action_taking_unit = null
	print("TURNING MOVEMENT LOOK ON")
	mouse_pos_offset = position.distance_to(get_global_mouse_position())
	toggle_moving_appearance("on")
	current_state = state.Moving
func exit_movement_state():
	current_state = state.Idle
	toggle_moving_appearance("off")
	if Globals.moving_unit == owner:
		Globals.moving_unit = null
	owner.global_position = global_start_turn_position
 

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
	current_movement_modifier = Utils.sum_dict_values(movement_modifieres)
	print("RECALCULATING MOVEMENT MODIFIERS")
func process(delta):
	if current_state == state.Moving:
		call_deferred_thread_group("move", owner.size)# move(owner.size)
 

func move(size_of_scene):
	## get the current position of the parent scene
	## save it as the last position
	## compare the distance between the last position and the new position
	## new position will be the position of the mouse - the mouse offset
	print("CALLED MOVEMENT")
	if Globals.moving_unit != owner:
		return
	var mouse_pos = get_global_mouse_position() 
	var new_position = global_position
	var distance_just_traveled = 0  #last_position.distance_to(mouse_pos )#0
	new_position = mouse_pos - size_of_scene / 2#mouse_pos - mouse_pos_offset#mouse_pos - size_of_scene / 2
	if floor( owner.position.distance_to(mouse_pos) ) <= 1 :
		distance_just_traveled =  0
	else:
		distance_just_traveled = floor( owner.position.distance_to(new_position) ) * current_movement_modifier  
	remain_distance -= distance_just_traveled
	owner.position= new_position
	var can_move = true
	for unit in get_tree().get_nodes_in_group("living_units"):
		if unit == get_parent():
			continue  # Skip checking collision with itself.
		if unit.get_node("CollisionArea").get_overlapping_areas().has($"."/CollisionArea):
			can_move = false
			break
	if not can_move: 
		abort_movement()
		exit_movement_state()
#		use_movement_component_abort()
#	return  new_position  
#	Globals.moving_unit = null 
#	toggle_moving_appearance("off")	
#	global_position = $movement_comp.abort_movement()
#	print("POSNOW", global_position, position)
#
 
func deselect_movement():
	global_start_turn_position = global_position
	exit_movement_state()
#	toggle_moving_appearance("off")	
#	if Globals.moving_unit == owner:
#		remain_movement -= 1
#		Globals.moving_unit = null 


func abort_movement():
	print("CALLED ABORT MOVEMENT ", global_start_turn_position)
	Globals.moving_unit = null
	remain_distance = base_movement_range
	owner.position = global_start_turn_position
	call_deferred_thread_group("exit_movement_state")
#	return    global_start_turn_position       
	

func process_for_next_turn():
	remain_movement =  base_movement_points
	remain_distance = base_movement_range
	set_new_start_turn_point()  
	owner.position = global_start_turn_position
#	return global_start_turn_position
	
func  set_new_start_turn_point():
	print("SETTING NEW START TURN POS",global_position)
	global_start_turn_position = global_position
