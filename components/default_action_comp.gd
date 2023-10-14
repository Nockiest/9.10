extends Area2D
class_name DefaultAttackComponent
signal remain_actions_updated(new_attacks)
var base_actions:int = 1
var remain_actions: int = base_actions:
	set(new_attacks):
		remain_actions = new_attacks
		emit_signal("remain_actions_updated", new_attacks)
var units_in_action_range:Array= []
var base_action_range:int = 100:
	set(value):
		base_action_range = value
		action_range =floor( base_action_range * Utils.sum_dict_values(aciton_range_modifiers))
var action_range:int = base_action_range:
	get:
		return action_range
	set(value):
		action_range = value
		units_in_action_range = []
		$AttackRangeShape.shape = CircleShape2D.new()
		$AttackRangeShape.shape.radius = action_range
var aciton_range_modifiers = {
	"base_modifier": 1,
	"observer": 0
	}:
	set(value):
		print("VALUE AUGMENTED", base_action_range *Utils.sum_dict_values(aciton_range_modifiers))
		aciton_range_modifiers = value
		action_range = floor( base_action_range * Utils.sum_dict_values(aciton_range_modifiers))
var center
var highlight_color = "white"

func update_from_observer_boost():
	action_range = base_action_range * Utils.sum_dict_values(aciton_range_modifiers)
	print("NEW ACTION RANGE", action_range)
func try_attack( ):
	print("processing", Globals.hovered_unit,Globals.action_taking_unit  )
	if !check_can_attack():
		print("FAILED ",self, self.get_parent(),  check_can_attack() )
		return  "FAILED"
	if not Globals.hovered_unit in units_in_action_range:
		print_debug(2)
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
	for unit in units_in_action_range:
		unit.get_node("ColorRect").modulate = Color(highlight_color)
 
func unhighlight_units_in_range():
	for enemy in units_in_action_range:
		enemy.get_node("ColorRect").modulate = enemy.color

func _on_area_entered(area):
#	print(area, area.get_parent(), "AREA", area is BattleUnit )
 
	if area.get_parent() == owner:
#		print_debug("FAIL")
		return 2
	if area.name != "CollisionArea": 
#		print_debug("isnt unit", area.name)
		return 3
	if  area.get_parent().color == null:
#		print_debug("FAIL")
		return 5
	if area.get_parent().color == owner.color:
#		print_debug("ISNT SAME COLOR",area.get_parent().color , owner.color )
		return "SAME COLOR"
	units_in_action_range.append(area.get_parent())
	return 6


func process_action():
	print("CHILDReN OF THIS COMPONENT SHOULd HAVE ATTACK IN THEM")

func _on_area_exited(area):
	if area.name == "CollisionArea" and units_in_action_range.has(area.get_parent()):
		units_in_action_range.erase(area.get_parent()) 
 
