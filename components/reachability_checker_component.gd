class_name ReachabilityCheckerComp
extends Node2D

var TARGET: Area2D 
 
func _on_RayCast2D_ray_casted():
	$RayCast2D.enabled = true
	var colliding_object = $RayCast2D.get_collider()
	if colliding_object:
		print("Ray hit:", colliding_object)
		
 
 
		
func _process(delta):
	if TARGET:
		$RayCast2D.target_position =  to_local(Utils.get_collision_shape_center(TARGET))
func check_trajectory_without_trees(end_point:Vector2) -> void:
#	 Assuming the RayCast2D node is a child of this node
	var raycast = $RayCast2D
	var direction_to_end_point = global_position.direction_to(end_point  )
	var distance = global_position.distance_to(end_point  )
	# Set the starting position of the ray (in local coordinates) 
	# Set the direction and length of the ray
#	raycast.cast_to = direction_to_end_point * distance
#	raycast.force_raycast_update()
#	var collision_object = raycast.get_collider()
#	if collision_object:
#		print("RAY CAST COLLIDED WITH ", collision_object)
#        do_something_related_to_target()
func _ready():
	$RayCast2D.position = Vector2(0, 0)  # Adjust as needed
 
