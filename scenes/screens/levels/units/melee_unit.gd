extends BattleUnit
class_name MeleeUnit
 
#func try_attack():
#	if super.try_attack() == "success":
#		$melee_attack_comp.try_attack(  )
#
func _ready():
 
	action_component =$ActionComponent/melee_attack_comp
	action_component.base_action_range = 150
	super._ready()
	unit_name = "melee_unit"
func update_stats_bar():
	super.update_stats_bar()
	if action_component == null:
		return
	$UnitStatsBar/VBoxContainer/Attacks.text = "Attacks "+str(action_component.remain_actions)
