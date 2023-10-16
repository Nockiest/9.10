class_name ReachabilityCheckerComp
extends Node2D

@export var entity_mask_indexes:Array = []
func check_position_reachable(point, projectile_size):
	print("CHECKING POSITION REACHABLE")
	var raycast = RayCast2D.new()
	var collision_shape = CollisionShape2D.new()
	raycast.add_child(collision_shape)

	# Create a RectangleShape2D to represent the width of the "ray"
	var rectangle_shape = RectangleShape2D.new()
	rectangle_shape.extents = Vector2(projectile_size, 1)  # Adjust the width here

	# Set the shape of the CollisionShape2D
	collision_shape.shape = rectangle_shape
	for index in range(16):
		if index in entity_mask_indexes:
			raycast.set_collision_mask_value(index , true)
		else:
			raycast.set_collision_mask_value(index, false)
#		rasycast.set_collision_mask_value(1, true)
	print(raycast.get_collision_mask_value(7))
	add_child(raycast)
	raycast.collide_with_areas = true
	# Set the starting position of the ray (assuming your units have a position property)
	raycast.position = position#unit.position

	# Set the direction and length of the ray to reach the target unit
	raycast.target_position = to_local(point )#- target_unit.position
#		for index in attack_obstructions_layer_indexes:
	# Check if the ray hits anything
	raycast.force_raycast_update()
	var timer = Timer.new()
#	timer.wait_time = 2.0  # Set the time in seconds
#	timer.one_shot = true
#	add_child(timer)
#	timer.start()

#	timer.connect("timeout", _on_timer_timeout   )
	if raycast.is_colliding():
	# There is an obstruction between the units
		print(raycast.get_collider(),"  ", raycast.get_collision_point())
#		print("Obstruction detected between ", unit.unit_name, " and ", owner.unit_name)
#		raycast.queue_free()
		return false
	else:
	# The line is clear
#		print( owner.unit_name , " can attack ", unit.unit_name  )
#		reachable_units.append(unit)
#		raycast.queue_free()
		return true
		
 
 

# Function called when the timer times out
#func _on_timer_timeout(raycast):
#	raycast.queue_free()
#	print("RayCast2D removed after 2 seconds.")

#var TARGET: Area2D 
#
#func _on_RayCast2D_ray_casted():
#	$RayCast2D.enabled = true
#	var colliding_object = $RayCast2D.get_collider()
#	if colliding_object:
#		print("Ray hit:", colliding_object)
#
#
#
#
#func _process(delta):
#	if TARGET:
#		$RayCast2D.target_position =  to_local(Utils.get_collision_shape_center(TARGET))
#func check_trajectory_without_trees(end_point:Vector2) -> void:
##	 Assuming the RayCast2D node is a child of this node
#	var raycast = $RayCast2D
#	var direction_to_end_point = global_position.direction_to(end_point  )
#	var distance = global_position.distance_to(end_point  )
#	# Set the starting position of the ray (in local coordinates) 
#	# Set the direction and length of the ray
##	raycast.cast_to = direction_to_end_point * distance
##	raycast.force_raycast_update()
##	var collision_object = raycast.get_collider()
##	if collision_object:
##		print("RAY CAST COLLIDED WITH ", collision_object)
##        do_something_related_to_target()
#func _ready():
#	$RayCast2D.position = Vector2(0, 0)  # Adjust as needed
 
