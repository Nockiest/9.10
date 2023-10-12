class_name  SupportAction
extends DefaultAttackComponent
 
var supported_entity
var buffed_variable = "action_range"
var increase_ammount = 200
var color = Color(1, 0.75, 0.8) 
var area_support = false
func _ready():
	$SupportConnnection.modulate = color
	$SupportConnnection.z_index = 1000
	base_action_range = 100
	super._ready()
#enum support_comp_state {
#	no_support_connection,
#	new_support_connection,
#	support_already_provided
#}
#var current_state:State  = support_comp_state.no_support_connection
func _process(_delta):
	super._process(_delta)
	draw_line_to_supported_entity()

#	match current_state:
#		current_state.no_support_connection :
#			print("NOT PROVIDING SUPPORT CONNECTION")
#		current_state.new_support_connection :
#			print("CREATED NEW SUPPORT CONNECTION")
#		current_state.support_already_provided:
#			print("ALREADY PROVIDED SUPPORT")

func deselect_supported_entity():
	supported_entity = null
	unhighlight_units_in_range()

func check_can_support():
	if Globals.hovered_unit == owner or Globals.hovered_unit == null or Globals.hovered_unit == supported_entity:
		print(owner," 1")
		deselect_supported_entity()
		return false
	if Globals.hovered_unit.color != owner.color:
		print(owner," 2")
		return false
	if Globals.action_taking_unit  != owner:
		print(owner," 3")
		return false
	if  Utils.get_collision_shape_center( owner.get_node("CollisionArea") ).distance_to(Utils.get_collision_shape_center(owner.get_node("CollisionArea") )) > action_range:
		print(owner," 5")
		return false
	return true

func choose_supported():
#	print("CHOOSING SUPPORTED", check_can_support())
	if not check_can_support(): 
		#deselect_supported_entity()
		return
#	print("PASSED THE TEST")
	supported_entity = Globals.hovered_unit
	toggle_action_screen()
	return "SUCCESS"
 
 
## currently when i want to provide a buff on the enemy turn, it wouldnt work
func provide_buffs():
	if area_support:
		return
	if owner.color  != Color(Globals.cur_player):
		return
	if supported_entity:
		var entity_to_buff = supported_entity if buffed_variable in supported_entity else Utils.find_child_with_variable(supported_entity, buffed_variable)
		print(entity_to_buff, "ENTITY TO BUFF")
		if entity_to_buff and entity_to_buff.get(buffed_variable) != null:
			entity_to_buff.set(buffed_variable, entity_to_buff.get(buffed_variable) + increase_ammount)
 
 
func update_for_next_turn():
	provide_buffs()
	

func draw_line_to_supported_entity():
	$SupportConnnection.clear_points()  # Clear any existing points
	if supported_entity != null:
		# Convert global positions to Line2D's local space
		var local_start =to_local(owner.get_node("Center").global_position ) # $SupportConnnection.to_local(owner.center)
		var local_end = to_local( supported_entity.get_node("Center").global_position    ) #$SupportConnnection.to_local( supported_entity.center  )  
		$SupportConnnection.add_point(local_start)  # Add the parent's position as a point
		$SupportConnnection.add_point(local_end )  # Add the supported entity's position as a point
		# Calculate the distance between the start and end points
		if not  get_overlapping_areas().has(supported_entity.get_node("CollisionArea")):
			deselect_supported_entity()
 
#			var distance = local_start.distance_to(local_end)
#		if distance > action_range:
#			deselect_supported_entity()
#			return
 
 
func _on_area_entered(area):
	if area.name != "CollisionArea": 
		return  
	if area.owner.color != owner.color:
		return
	if str(super._on_area_entered(area)) == "SAME COLOR":
		print("observer area entered",area.get_parent(),area.owner.color ,owner.color,  get_parent( ))
		if area.owner.color != owner.color:
			return
		units_in_action_range.append(area.get_parent())

#    def find_obstacles_in_line_to_enemies(self, enemy, line_points):
#        # I could only reset the line to that specific unit instead of deleting the whole array
#        ######################### x FIND BLOCKING UNITS ##############
#        blocked = False
#        for unit in game_state.living_units.array:
#            if unit == enemy:
#                continue
#            elif unit.color == self.color:
#                continue
#            point_x, point_y, interferes = check_precalculated_line_square_interference(
#                unit, line_points)
#            distance_between_units = get_two_units_center_distance(unit  , enemy )
#
#            if interferes and abs(distance_between_units )> max(enemy.size//2, unit.size//2):
#                print("this unit is blocking the way", unit, enemy)
#                blocked = True
#                self.lines_to_enemies_in_range.append({
#                    "enemy": enemy,
#                    "start": self.center,
#                    "interference_point": (point_x, point_y),
#                    "end": enemy.center})
#
#                break
#        if not blocked:
#            self.lines_to_enemies_in_range.append({
#                "enemy": enemy,
#                "start": self.center,
#                "interference_point": None,
#                "end": enemy.center})
#
#        return blocked
#
  
#    def draw_lines_to_enemies_in_range(self):
#        for line in self.lines_to_enemies_in_range:
#            start = line["start"]
#            end = line["end"]
#            interference_point = line["interference_point"]
#
#            if interference_point is not None:
#                pygame.draw.line(screen, DARK_RED, start,
#                                 interference_point, 3)
#                pygame.draw.line(screen, (HOUSE_PURPLE),
#                                 interference_point, end, 3)
#            else:
#                pygame.draw.line(screen, DARK_RED, start, end, 3)
#                midpoint = ((start[0] + end[0]) // 2,
#                            (start[1] + end[1]) // 2)
#                distance = math.sqrt(
#                    (start[0] - end[0]) ** 2 + (start[1] - end[1]) ** 2)
#                font = pygame.font.Font(None, 20)
#                text_surface = font.render(
#                    f"{int(distance)} meters", True, WHITE)
#                text_rect = text_surface.get_rect(center=midpoint)
#                screen.blit(text_surface, text_rect)
# 
 

 
#func _draw():
#	var local_start_turn_pos  = to_local(global_start_turn_position)
#	if Globals.moving_unit == self:
#		var fill_color = Utils.lighten_color(color, 0.4)
#		# Draw an arc from 0 to PI radians (half a circle).
#		draw_arc(local_start_turn_pos, base_movement_range, 0,  PI*2, 100, fill_color, 3)
#		# Set the collision shape to match the drawn circle. 

 
