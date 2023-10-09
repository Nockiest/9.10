extends Node

#func lighten_color(color: Color, amount: float) -> Color:
#
#	var h = color.h
#	var s = color.s
#	var v = min(color.v - amount, 1)
#	return Color.from_hsv(h, s, v, color.a)
 
#func is_town_far_enough(  new_coors, min_distance, towns):
#	for town in towns:
#		var distance = new_coors.distance_to(town.center)
#		if distance < min_distance:
#			return false
#	return true
func are_points_far_enough(a:Vector2, b:Vector2, min_distance:int):
	return a.distance_to(b) > min_distance
	
func find_child_with_variable(parent, variable):
	for child in parent.get_children():
		if variable in child:
			return child
	return null

#func debug(position: Vector2, value):
#	# Create a new Label node.
#	var label = Label.new()
#	# Set the text of the label to the value.
#	label.text = str(value)
#	# Set the position of the label.
#	label.position = position
#	# Add the label as a child of the current node.
#	add_child(label)
#
#	# Create a new Timer node.
#	var timer = Timer.new()
#	# Set the timer to one-shot mode and start it with a delay of 5 seconds.
#	timer.set_one_shot(true)
#	timer.start(0.1)
#	# Connect the timeout signal of the timer to a function that removes the label.
#
#	# Add the timer as a child of the current node.
#	add_child(timer)
#	label.queue_free()

 
## you have to put this variable wheter you want to put the z_indexes
#var nodes_list = []
#func get_z_indexes(node,nodes_list):
#	if node is CanvasItem:
#		nodes_list.append([node, node.z_index])
#	for child in node.get_children():
#		get_z_indexes(child,nodes_list)
#func sort_by_z_index_desc(a, b):
#	return a[1] < b[1]
 
func get_collision_shape_center(area: Area2D, node_name: String= "CollisionShape2D") -> Vector2:
	var shape = area.get_node(node_name).shape 
	if shape is RectangleShape2D:
		var rect_shape =  shape   as RectangleShape2D
		return area.global_position  + Vector2(rect_shape.extents.x, rect_shape.extents.y)
	elif  shape is CircleShape2D:
#		var circle_shape =  shape #as CircleShape2D
		return  area.global_position 
	else:
		assert (false, "Unsupported collision shape type")
		return Vector2(0, 0)
 
func play_animation_at_position(animation_node, animation  , position: Vector2) -> void:
	if animation_node == null:
		print("No animation found with name: ", animation_node)
		return
	animation_node.z_index = 100000
	animation_node.show()
	# Set the position of the animation
	animation_node.global_position = position

	# Play the animation
#	animation.play()
	animation_node.play(animation)
	print("playing animation",animation_node, animation  , position)
	# Hide the animation after it finishes playing
	await animation_node.animation_finished 
	animation_node.hide()

func get_random_point_in_square(square_size: Vector2) -> Vector2: ## shape extents only return half the size of the collision shape
	var random_x = randi_range(0, int(square_size.x))
	var random_y = randi_range(0, int(square_size.y))
#	print(Vector2(random_x, random_y),square_size.x," ",square_size.y)
	return Vector2(random_x, random_y)

## doesnt work how I intended
func lighten_color(color: Color, points: int) -> Color:
	# Convert the color to RGB format
	var r = int(color.r * 255)
	var g = int(color.g * 255)
	var b = int(color.b * 255)

	# Subtract the specified number of points from each color component
	r = max(0, r - points)
	g = max(0, g - points)
	b = max(0, b - points)

	# Convert the lightened color back to Color format
	return Color(r / 255.0, g / 255.0, b / 255.0)
 
## untested
func area_to_line2d(area: Area2D, width: float) -> Line2D:
	var line = Line2D.new()
	line.width = width
	for shape in area.get_shapes():
		if shape is CollisionPolygon2D:
			var points = shape.shape.get_points()
			for i in range(points.size()):
				line.add_point(points[i])
	return line

## tested
func polygon_to_line2d(polygon: Polygon2D, width: float, color: Color = Color(1, 1, 1, 1)) -> Line2D:
	var line = Line2D.new()
	var vertecies = polygon.get_polygon()
	vertecies.append(vertecies[0]) ## so the line is circumnavigating the whole polygon
#	print(vertecies)
	line.width = width
	line.modulate = color
	for i in range( len(vertecies) ):
		line.add_point(vertecies[i])
	return line
	
func sum_dict_values(dict: Dictionary) -> float:
	var sum = 0.0
	for value in dict.values():
		if typeof(value) == TYPE_INT || typeof(value) == TYPE_FLOAT:
			sum += value
		else:
			assert(false, "DICTIONARY ISNT COMPLETELY MADE OF NUMBERS")
	return sum
	
func orientation(p, q, r):
		var val = (q[1] - p[1]) * (r[0] - q[0]) - (q[0] - p[0]) * (r[1] - q[1])
		if val == 0:
			return 0
		return 1 if val > 0 else 2

func do_lines_intersect(p1, p2, p3, p4):

 
	var o1 = orientation(p1, p2, p3)
	var o2 = orientation(p1, p2, p4)
	var o3 = orientation(p3, p4, p1)
	var o4 = orientation(p3, p4, p2)

	if o1 != o2 and o3 != o4:
		if min(p1[0], p2[0]) <= max(p3[0], p4[0]) and min(p3[0], p4[0]) <= max(p1[0], p2[0]) and \
			min(p1[1], p2[1]) <= max(p3[1], p4[1]) and min(p3[1], p4[1]) <= max(p1[1], p2[1]):
			# Calculate the point of intersection
			var intersect_x = (o1 * p3[0] - o2 * p4[0]) / (o1 - o2)
			var intersect_y = (o1 * p3[1] - o2 * p4[1]) / (o1 - o2)
			return Vector2(intersect_x, intersect_y)

	return false

#func generate_bezier_curve(start:Vector2, end:Vector2, control_point:Vector2,  num_segments:int) -> Array:
#	var points = []
#	var t:float = 0
#	while t <= 1:
#		# Define the control points for the Bézier curve 
##		var control_point_2 = Vector2(50, 100)
#		var q0 = start.lerp(control_point, t)
#		var q1 = control_point.lerp(end , t)
#		var point = q0.lerp(q1, t)
#		# Generate two random points between the start and end points
#		points.append(point)
#		t += 1.0/num_segments
#	return points
func generate_bezier_curve(start:Vector2, end:Vector2, control_point:Vector2,  num_segments:int):
	var t:float = 0
	var points = []
	var segments = []
	while t <= 1:
		# Define the control points for the Bézier curve 
		var q0 = start.lerp(control_point, t)
		var q1 = control_point.lerp(end , t)
		var point = q0.lerp(q1, t)
		# Generate two random points between the start and end points
		points.append(point)
#		print(line.points.size)
		if len( points) >= 2:
			segments.append([ round(points[-1]), round(points[-2]) ])
		t += 1.0/num_segments
	return segments


#func _on_timer_timeout(sprite):
#    # Remove the Sprite node from the scene tree when the timer times out
#	sprite.queue_free()
#func move():
#	var mouse_pos = get_global_mouse_position()
#	var distance_to_mouse = global_start_turn_position.distance_to(mouse_pos)
#	var new_position = position
#	if distance_to_mouse > base_movement:
#		var direction_to_mouse = (mouse_pos - global_start_turn_position).normalized()
#		new_position = global_start_turn_position + direction_to_mouse * base_movement - size / 2
#	else:
#		new_position = mouse_pos - size / 2
#	var temp_area = Area2D.new()
#	var temp_collision_shape = CollisionShape2D.new()
#	temp_collision_shape.shape = $CollisionArea/CollisionShape2D.shape.duplicate()
#	temp_area.add_child(temp_collision_shape)
#	get_tree().get_root().add_child(temp_area)
#	temp_area.global_position = new_position
#	# Check for collisions with other units.
#	var can_move = true
#	for unit in get_tree().get_nodes_in_group("living_units"):
#		if unit == self:
#			continue  # Skip checking collision with itself.
#		var overlapping_areas = unit.get_node("CollisionArea").get_overlapping_areas()
#		if overlapping_areas.has(temp_area):
#			can_move = false
#			print("CollisionArea overlapping areas: ", overlapping_areas)
#			print("temp_area: ", temp_area)
#			break
#	# Update the position if no collisions were detected.
#	if can_move:
#		position = new_position

#func move():
#	# Get the position of the mouse cursor.
#	var mouse_pos = get_global_mouse_position()
#
#	# Calculate the direction and distance to the mouse position.
#	var direction = (mouse_pos - position).normalized()
#	var distance = position.distance_to(mouse_pos)
#	var distance_to_mouse = global_start_turn_position.distance_to(mouse_pos)
#	# Move the character towards the mouse position.
#	var velocity = direction * speed
#	# Check if the character has reached the mouse position.
#	if distance_to_mouse < base_movement:
#		position = mouse_pos - size / 2		
#		move_and_slide(  )
