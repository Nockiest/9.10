class_name MovementComponent
extends Node2D
signal remain_movement_changed( )
const base_movement_points:int = 1
const base_movement_range:int = 500  
@onready var global_start_turn_position :Vector2 =  to_global(position)#get_global_transform().get_origin() # Vector2((position[0]+round(size[0]/2)),(position[1]+round(size[1]/2)))
var remain_distance  = base_movement_range:
	set(new_distance):
		remain_distance =new_distance 
		emit_signal("remain_movement_changed"  )
		if new_distance < 0 :
			abort_movement()
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
#		current_movement_modifier = Utils.sum_dict_values(movement_modifieres)
	get:
		return movement_modifieres
var current_movement_modifier = Utils.sum_dict_values(movement_modifieres)
var on_bridge:bool = false
func _ready():
	$MovementRangeArea/MovementRangeArea.shape = CircleShape2D.new()
	$MovementRangeArea/MovementRangeArea.shape.radius = base_movement_range
	$MovementRangeArea/MovementRangeArea.hide()
	global_start_turn_position =  global_position  
	
func move(size_of_scene, center):
	var mouse_pos = get_global_mouse_position()
#	var distance_to_mouse = global_start_turn_position.distance_to(mouse_pos) 
	var new_position = global_position
	var distance_just_traveled =  0
 
	new_position = mouse_pos - size_of_scene / 2
	if floor( owner.center.distance_to(mouse_pos) ) <= 1 :
		distance_just_traveled =  0
	else:
		distance_just_traveled = floor( owner.center.distance_to(mouse_pos) ) * current_movement_modifier 
#	print("DISTANCE JUST TRAVELED", distance_just_traveled, " ", global_position, " ", mouse_pos)
	global_position = new_position 
	remain_distance -= distance_just_traveled
 
	return  global_position 
		
func abort_movement():
 
	Globals.moving_unit = null
	global_position = global_start_turn_position
	remain_distance = base_movement_range
	#print(   global_start_turn_position, "AFTER")
	return    global_start_turn_position       
	
func process_for_next_turn():
	remain_movement =  base_movement_points
	remain_distance = base_movement_range
	#print("set_new_start_turn_point")
	#print(global_start_turn_position,global_position, parent_size, "VALUES BEFORE SETTING NEW START POS")
	set_new_start_turn_point() #$CollisionArea/CollisionShape2D.global_position +$CollisionArea/CollisionShape2D.shape.extents/2 
	return global_start_turn_position
	
func  set_new_start_turn_point():
	global_start_turn_position = global_position
	position = to_local(global_start_turn_position)
	return global_start_turn_position
