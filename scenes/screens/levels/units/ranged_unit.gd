extends BattleUnit
class_name RangedUnit
 
var start_ammo = 6
var bullet_scene:PackedScene = preload("res://scenes/screens/levels/projectiles/bullet.tscn")
#var ranged_unit_range = 300
func _ready():
	action_component = $ActionComponent/RangedAttackComp 
 
	action_component.max_ammo = start_ammo 
	action_component.ammo = start_ammo 
#	action_component.action_range = ranged_unit_range
#	action_component.position = to_local(center)
	action_component.owner =self
	super._ready()
	unit_name = "ranged_unit"
#	action_range = 300 
#	$RangedAttackComp.base_action_range = base_action_range   
 
#func toggle_action_screen(): 
#	var ranged_action_component = $RangedAttackComp
#	if ranged_action_component.ammo <= 0:
#		return
#	super.toggle_action_screen() 
 
func update_stats_bar():
	super.update_stats_bar()
	if action_component:
		$UnitStatsBar/VBoxContainer/Ammo.text = "Ammo "+str(action_component.ammo)
		$UnitStatsBar/VBoxContainer/Attacks.text = "Attacks "+str(action_component.remain_actions)

func _on_ranged_attack_comp_ammo_changed(_ammo):
	update_stats_bar()
