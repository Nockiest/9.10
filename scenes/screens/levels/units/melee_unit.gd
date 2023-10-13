extends BattleUnit
class_name MeleeUnit
 
func _ready():
	super._ready()
	unit_name = "melee_unit"
	action_component =$ActionComponent/melee_attack_comp
#	action_component.base_action_range = 150
func update_stats_bar():
	super.update_stats_bar()
	if action_component == null:
		return
 
