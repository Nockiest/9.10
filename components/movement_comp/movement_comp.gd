## move th emovement component to the center and do all the calculations from there
## move the unit only after checking, that the localtion is valid
## move only after checking that the line to the position is valid
## coor the line to see, which place is valid to move to
class_name MovementComponent
extends Node2D
signal remain_movement_changed( )
signal ran_out_of_movement()
var base_movement_range:int:
	set(new_range):
		base_movement_range = new_range
		remain_distance = base_movement_range 
var global_start_turn_position :Vector2 #=  owner.global_position -owner.size/2
@onready var buy_areas = get_tree().get_nodes_in_group("buy_areas")
#@export var movement_sounds:Array[AudioStream] = []
var remain_distance  = base_movement_range:
	set(new_distance):
		remain_distance =new_distance 
		emit_signal("remain_movement_changed"  )
		if new_distance < 0 :
			abort_movement()
			remain_distance =  base_movement_range
			owner.update_stats_bar()
			emit_signal("ran_out_of_movement") 
	get:
		return remain_distance
var movement_modifiers:Dictionary = {
	"base_modifier": 1,
	"on_road": 0,
	"in_forrest": 0,
} 
var current_movement_modifier #=  calculate_total_movement_modifier()
var on_bridge:bool = false 
var on_river:bool= false
var mouse_pos_offset: Vector2 #= Vector2(0,0)
enum state {
	Idle,
	Moving,
	Placed
}
var current_state:state = state.Idle
 
func _ready():
	await owner._ready()
	call_deferred_thread_group("calculate_total_movement_modifier")
	global_start_turn_position = owner.global_position -owner.size/2

func enter_movement_state():
	if not check_can_turn_movement_on():
		exit_movement_state() 
		return 
	$Line2D.clear_points()
	$AudioStreamPlayer.play()
	Globals.moving_unit = owner
	Globals.action_taking_unit = null
	print("TURNING MOVEMENT LOOK ON")
 
	toggle_moving_appearance("on")
	current_state = state.Moving
	$SelectSound.play()
#	$MovementSoundPlayer.should_play_sounds = true
func exit_movement_state():
	owner.get_node("UnitStatsBar").visible = false
	$Line2D.clear_points()
	$AudioStreamPlayer.stop()
	current_state = state.Idle
	toggle_moving_appearance("off")
	if Globals.moving_unit == owner:
		Globals.moving_unit = null
 
func exit_placed_state():
	print("EXITING PLAcED STATE",  owner.center, to_global(owner.center), owner.position, owner.get_node("Center").global_position)
	current_state = state.Idle
	global_start_turn_position = owner.global_position#center
#	owner.global_position = global_start_turn_position#Vector2(global_start_turn_position.x + mouse_pos_offset.x, global_start_turn_position.y + mouse_pos_offset.y) 
func enter_placed_state():
	current_state = state.Placed
	owner.is_newly_bought = false

func toggle_moving_appearance(toggle):
	if toggle == "on":
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
	owner.update_stats_bar() #PRO4 TO NEFUNGUJE??
 
func process(_delta):
#	$MovementSoundPlayer.process(current_state)
	calculate_total_movement_modifier()
	if current_state == state.Placed: 
		owner.position = get_global_mouse_position() - owner.size / 2
#		print("OWNER POS ", owner.position)
		if Input.is_action_just_pressed("left_click"):
			process_unit_placement()
	elif current_state == state.Moving:
		move()#call_deferred_thread_group("move"  ) 
		if Input.is_action_just_pressed("right_click"):
			abort_movement()
		elif Input.is_action_just_pressed("left_click"):
#			set_new_start_turn_point()
			set_owner_position($NewPosition.global_position-owner.size/2)
			exit_movement_state()
	elif current_state == state.Idle:
		if Input.is_action_just_pressed("left_click"):
			enter_movement_state()

func get_area_at_position():
	pass

func check_can_turn_movement_on():
	if Globals.hovered_unit != get_parent():
#		print("CASE 2")
		return false
	elif Globals.action_taking_unit != get_parent() and Globals.action_taking_unit != null:
#		print("CASE 3")
		return false
	elif Globals.action_taking_unit != null:
#		print("CASE 4")
		return false
	elif Globals.placed_unit != null:
#		print("case 5")
		return false
	return true
 
func move( ):
	owner.get_node("UnitStatsBar").visible = true
	if Globals.moving_unit != owner:
		return
	if on_river and not on_bridge and movement_modifiers["on_road"] == 0:
		abort_movement()
	var mouse_pos = get_global_mouse_position()
	
	if $NewPosition.position == mouse_pos:
		return 0
	$Line2D.add_point(to_local(mouse_pos))
	var segment_difficulty =get_segment_move_difficulty(mouse_pos)
	var new_position =  mouse_pos  #  - mouse_pos_offset  
	var old_position = $NewPosition.global_position#owner.global_position
	print(  round(new_position.distance_to(old_position))   * segment_difficulty," ",  round(new_position.distance_to(old_position))  ," ", new_position, " ", old_position," ", segment_difficulty)
	var distance_just_traveled =  round(new_position.distance_to(old_position))   * segment_difficulty#current_movement_modifier  
	remain_distance -= distance_just_traveled
	$NewPosition.global_position = new_position
 
func abort_movement():
	print("CALLED ABORT MOVEMENT ", global_start_turn_position)
	Globals.moving_unit = null
	remain_distance = base_movement_range
	set_owner_position(global_start_turn_position-owner.size/2 )  
	exit_movement_state() 
 
func get_segment_move_difficulty(new_pos) -> float:
	$RayCast2D.position = $NewPosition.position#to_local($NewPosition.global_position)  #$Line2D.get_point_position( $Line2D.get_point_count() -1) 
	$RayCast2D.target_position = new_pos -$RayCast2D.global_position #+Vector2(1,1) #to_local( new_pos ) 
	$RayCast2D.force_raycast_update()
	var point_count = $Line2D.get_point_count()

	if point_count > 5:
		$RayCast2D.position = $Line2D.get_point_position(-5)
	elif point_count == 1:
		$RayCast2D.position = $Line2D.get_point_position(point_count-1)
	else:
		$RayCast2D.position =to_local( owner.center)
		
	var segment_difficulty = 1
	if $RayCast2D.is_colliding():
		var collider = $RayCast2D.get_collider()
		var collider_parent = collider.get_parent()
		
		# Check if the collider is the owner of the component
		if collider.get_parent() is BattleUnit and collider == owner.get_node("CollisionArea"):
			return segment_difficulty  # Skip further processing for self collisions
 
		if collider_parent is RiverSegment:
			segment_difficulty = 10000
			print(1)
		elif collider_parent.get_parent() is Forrest:
			segment_difficulty += 0.5
			print(2)
		elif collider_parent is Road:
			segment_difficulty -= 0.5
			print(3)
		elif collider_parent is Bridge:
			segment_difficulty -= 0.5
			print(4)
		elif collider_parent is BattleUnit:
			segment_difficulty = 10000
			print(5)
#	print(segment_difficulty, $RayCast2D.global_position,$RayCast2D.position,$RayCast2D.target_position  )
	return segment_difficulty  
 
## A very ugly way to deceslect movement
func set_owner_position(new_position):
	$Line2D.clear_points()
	owner.global_position = new_position 
	owner.center = owner.get_node("Center").global_position
	
func process_for_next_turn():
	remain_distance = base_movement_range
	set_new_start_turn_point()  


func  set_new_start_turn_point():
	print("SETTING NEW START TURN POS",global_position)
	global_start_turn_position = owner.global_position + owner.size/2


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
		owner.queue_free()






#	var mouse_pos = get_global_mouse_position()
#	var x_distance = mouse_pos.x - global_position.x
#	var y_distance = mouse_pos.y - global_position.y
#	$RayCast2D.global_position = mouse_pos
#	mouse_pos_offset = Vector2(x_distance, y_distance)#global_position.distance_to(get_global_mouse_position())
#	print("MOUSE OFFSET ", mouse_pos_offset, mouse_pos, global_position)
