extends SupportAction
signal support_error()
func _ready():
	color = Color(0.9,0,0.2)
	super._ready()

func check_can_support():
	if Globals.hovered_unit is MeleeUnit:
		support_error.emit( )
		return false
	return super.check_can_support()

func provide_buffs():
	super.provide_buffs()
	if supported_entity != null:
#		print(supported_entity  , "SUPPORTED UNIT  ")
#		print(supported_entity.action_component , "SUPPORTED UNIT ACTION COMPONENT  ")
#		print(supported_entity.action_component.get("aciton_range_modifiers"), "SUPPORTED UNIT ACTION COMPONENT MODIFIERS")
#		print(supported_entity.action_component.get("aciton_range_modifiers")["observer"], "SUPPORTED UNIT ACTION COMPONENT MODIFIERS")
		var support_entity_action_comp = supported_entity.action_component.get("aciton_range_modifiers")
		support_entity_action_comp["observer"] = 1
		supported_entity.action_component.update_from_observer_boost()
		
func deselect_supported_entity():
	if supported_entity != null:
		var support_entity_action_comp = supported_entity.action_component.get("aciton_range_modifiers")
		support_entity_action_comp["observer"] = 0
		supported_entity.action_component.update_from_observer_boost()
	super.deselect_supported_entity()
