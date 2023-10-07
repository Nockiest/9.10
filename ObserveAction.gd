extends SupportAction
 
func _ready():
	color = Color(0.9,0,0)
	$SupportConnnection.modulate = color

func check_can_support():
	if Globals.hovered_unit is MeleeUnit:
		return false
	super.check_can_support()
