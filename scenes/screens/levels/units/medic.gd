class_name Medic
extends SupportUnit

func _ready():
 
	super._ready()
	action_component = $ActionComponent/HealingAction  
	unit_name = "medic"
