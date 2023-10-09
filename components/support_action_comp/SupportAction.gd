class_name  SupportAction
extends DefaultAttackComponent
 
var supported_entity
var buffed_variable = "action_range"
var increase_ammount = 200
var constant_buff = true
var buff_already_applied = false
var color = Color(1, 0.75, 0.8) 
var area_support = false
#var action_range = 150
func _ready():
	super._ready()
	$SupportConnnection.modulate = color
	$SupportConnnection.z_index = 1000
	action_range = 100
	$AttackRangeCircle.shape.radius = action_range
func deselect_supported_entity():
	if supported_entity and constant_buff and buff_already_applied:
		if buffed_variable in supported_entity :
			supported_entity.buffed_variable -= increase_ammount
	supported_entity = null
	buff_already_applied = false
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
	print("CHOOSING SUPPORTED", check_can_support())
	if not check_can_support(): 
		deselect_supported_entity()
		return
	print("PASSED THE TEST")
	supported_entity = Globals.hovered_unit
	toggle_action_screen()
	return "SUCCESS"
	
# connected to next turn button
## currently when i want to provide a buff on the enemy turn, it wouldnt work
func provide_buffs():
	if area_support:
		return
	if owner.color  != Color(Globals.cur_player):
		return
	if buff_already_applied and constant_buff:
		return
	if supported_entity:
		var entity_to_buff = supported_entity if buffed_variable in supported_entity else Utils.find_child_with_variable(supported_entity, buffed_variable)
	
		if entity_to_buff and entity_to_buff.get(buffed_variable) != null:
			entity_to_buff.set(buffed_variable, entity_to_buff.get(buffed_variable) + increase_ammount)
			buff_already_applied = true
		else:
			buff_already_applied = false
 
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
#		 
		
		print(get_overlapping_areas())
		if not  get_overlapping_areas().has(supported_entity.get_node("CollisionArea")):
			deselect_supported_entity()
#			deselect_supported_entity()
#			var distance = local_start.distance_to(local_end)
#		if distance > action_range:
#			deselect_supported_entity()
#			return

func _process(_delta):
	super._process(_delta)
	draw_line_to_supported_entity()
#
#func toggle_action_screen():
##	print( Globals.action_taking_unit == get_parent())
#	if Globals.action_taking_unit == get_parent():
#		Globals.action_taking_unit = null
#		Globals.attacking_component = null
#		print_debug("1 ", self)
#		return
#	if Globals.hovered_unit != get_parent():
#		print ("2 ", self,  Globals.hovered_unit)
#		return
#	if Globals.action_taking_unit != null:
#		print_debug("3 ", self)
#		return
#	## switch between moving and doing action
#	get_parent().deselect_movement()
#	Globals.action_taking_unit = get_parent()
#	Globals.attacking_component = self
#	print("ACTION TAKING UNIT", Globals.action_taking_unit)

 
func _on_area_entered(area):
 
	if str(super._on_area_entered(area)) == "SAME COLOR":
#		print("SUPPORT COMPONENT APPENDING AREA", area.get_parent())
		units_in_action_range.append(area.get_parent())
#		print(units_in_action_range, "NOW FRIENDLY UNITS IN RANGE ARE")

#func _on_area_exited(area):
#	if area.name == "CollisionArea" and units_in_action_range.has(area.get_parent()):
#		units_in_action_range.erase(area.get_parent()) 
 


#if area.get_parent() == owner:
#		return
#	if area.name != "CollisionArea":
#		return
#	if not (area.get_parent() is BattleUnit):
#		return
#
#	print(area.get_parent()   , owner, self )
#	if not(self is ArearResupplyAction):
#		if area.get_parent().color != owner.color: ## It will only accept same team units
#			return
#	if units_in_action_range.has(area.get_parent()) :
#		return
#	units_in_action_range.append(area.get_parent())
