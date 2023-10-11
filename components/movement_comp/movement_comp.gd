class_name MovementComponent
extends Node2D
signal remain_movement_changed( )
signal ran_out_of_movement()
const base_movement_points:int = 1
const base_movement_range:int = 500  
@onready var global_start_turn_position :Vector2 =  to_global(position) 
var remain_distance  = base_movement_range:
	set(new_distance):
		remain_distance =new_distance 
		emit_signal("remain_movement_changed"  )
		if new_distance < 0 :
			print("EMMITTING RAN OUT OF MOVEMENT")
			emit_signal("ran_out_of_movement") 
	get:
		return remain_distance
var remain_movement:int = base_movement_points:
	set(new_movement):
		remain_movement = new_movement
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
		current_movement_modifier = Utils.sum_dict_values(movement_modifieres)
		if movement_modifieres["on_road"] == 0 and on_bridge == false:
			ran_out_of_movement.emit()
	get:
		return movement_modifieres
var current_movement_modifier = Utils.sum_dict_values(movement_modifieres)
var on_bridge:bool = false 
var on_river:bool=false
func _ready():
	$MovementRangeArea/MovementRangeArea.shape = CircleShape2D.new()
	$MovementRangeArea/MovementRangeArea.shape.radius = base_movement_range
	$MovementRangeArea/MovementRangeArea.hide()
	global_start_turn_position =  global_position  
	
func move(size_of_scene):
	var mouse_pos = get_global_mouse_position() 
	var new_position = global_position
	var distance_just_traveled =  0
	new_position = mouse_pos - size_of_scene / 2
	if floor( owner.center.distance_to(mouse_pos) ) <= 1 :
		distance_just_traveled =  0
	else:
		distance_just_traveled = floor( owner.center.distance_to(mouse_pos) ) * current_movement_modifier 
#	print("DISTANCE JUST TRAVELED", distance_just_traveled, " ", global_position, " ", mouse_pos)
#	global_position = new_position 
	remain_distance -= distance_just_traveled
 
	return  new_position  
		
func abort_movement():
	print("CALLED ABORT MOVEMENT ", global_start_turn_position)
	Globals.moving_unit = null
#	global_position = global_start_turn_position
	remain_distance = base_movement_range
	return    global_start_turn_position       
	
func process_for_next_turn():
	remain_movement =  base_movement_points
	remain_distance = base_movement_range
	set_new_start_turn_point()  
	return global_start_turn_position
	
func  set_new_start_turn_point():
	print("SETTING NEW START TURN POS",global_position)
	global_start_turn_position = global_position
#	position = to_local(global_start_turn_position)
	return global_start_turn_position
