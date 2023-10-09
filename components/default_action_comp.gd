extends Area2D
class_name DefaultAttackComponent
signal remain_actions_updated(new_attacks)
var base_actions:int = 1
var remain_actions: int = base_actions:
	set(new_attacks):
		remain_actions = new_attacks
		emit_signal("remain_actions_updated", new_attacks)
var units_in_action_range:Array= []
var action_range:int = 100:
	get:
		return action_range
	set(value):
		action_range = value
		units_in_action_range = []
		$AttackRangeShape.shape = CircleShape2D.new()
		$AttackRangeShape.shape.radius = action_range
var attack_range_modifiers = {"base_modifier": 1}
var center

func try_attack( ):
	print("processing", Globals.hovered_unit,Globals.action_taking_unit  )
	if !check_can_attack():
		print("FAILED ",self, self.get_parent(),  check_can_attack() )
		return  "FAILED"
	if not Globals.hovered_unit in units_in_action_range:
		return "FAILED"
	## I will add this to the try_attack component later too
	print("TOGGLING")
	toggle_action_screen()
	attack()
	return "SUCESS"

## ranged attack has an overide for this function  
func attack():
	Globals.last_attacker = owner
	toggle_action_screen()

func check_can_attack():
	print("GLOBALS ", Globals.action_taking_unit, owner, Globals.action_taking_unit == owner )
	if  Globals.action_taking_unit != owner:
		print_debug(1, Globals.action_taking_unit)
		toggle_action_screen()
		return false
	if not Globals.hovered_unit:
		toggle_action_screen()
		print_debug(2,   Globals.hovered_unit)
		return false
	if Globals.hovered_unit.color == owner.color:
		toggle_action_screen()
		print_debug(3,  Globals.hovered_unit.color , owner.color)
		return false
	if remain_actions <= 0:
		print_debug(4,  remain_actions)
		return false
	print_debug(5)
	return true

func _ready():
	pass
 
func  update_for_next_turn():
	remain_actions = base_actions
	unhighlight_units_in_range()
func _process(_delta):
	if Globals.action_taking_unit == owner:
		$AttackRangeCircle.show()
	else:
		$AttackRangeCircle.hide()
 
func toggle_action_screen():
	if Globals.action_taking_unit == owner:
		Globals.action_taking_unit = null
		Globals.attacking_component = null
		unhighlight_units_in_range()
		print_debug("1 ", self)
		return
	if Globals.hovered_unit != owner:
		print_debug ("2 ", self,  Globals.hovered_unit)
		return
	if Globals.action_taking_unit != null:
		print_debug("3 ", self,  Globals.action_taking_unit)
		return
	## switch between moving and doing action
	owner.deselect_movement()
	if remain_actions > 0:
		Globals.action_taking_unit = owner
		highlight_units_in_range()
		Globals.attacking_component = self
	print("ACTION TAKING UNIT", Globals.action_taking_unit)
 
func highlight_units_in_range(): 
	print("HIGHLIGHTING UNITS", units_in_action_range)
	var other_units = get_tree().get_nodes_in_group("living_units")
	for enemy in other_units:
		if units_in_action_range.has(enemy):
			enemy.get_node("ColorRect").modulate = Color("white")
		else:
			enemy.get_node("ColorRect").modulate = enemy.color

func unhighlight_units_in_range():
	for enemy in units_in_action_range:
		enemy.get_node("ColorRect").modulate = enemy.color

func _on_area_entered(area):
#	print(area, area.get_parent(), "AREA", area is BattleUnit )
#	if units_in_action_range.has(area.get_parent()) :
#		return
	if not owner:
		return 1
	if area.get_parent() == owner:
		return 2
	if area.name != "CollisionArea": 
		return 3
	if not (area.get_parent() is BattleUnit):
		return 4
#	print("x",self, owner)
#	print( "x",owner.color)
	if  area.get_parent().color == null:
		return 5
	if area.get_parent().color == owner.color:
		return "SAME COLOR"
	units_in_action_range.append(area.get_parent())
	return 6
func process_action():
	print("CHILDReN OF THIS COMPONENT SHOULd HAVE ATTACK IN THEM")

func _on_area_exited(area):
	if area.name == "CollisionArea" and units_in_action_range.has(area.get_parent()):
		units_in_action_range.erase(area.get_parent()) 
 
