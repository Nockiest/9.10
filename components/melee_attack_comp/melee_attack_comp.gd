class_name MeleeAttackComp
extends DefaultAttackComponent
signal attack_failed
signal attack_suceeded

func _ready():
	super._ready()
	$SlashAnimation.hide()
	
func try_attack():
	print("CALLED TRY ATTACK")
	var res =super.try_attack()
	print("RES", res)
	if res!="SUCESS":
		print("ATTACK FAILED")
		return "FAILED"
	else:
		print("ATTACK_SUCESS")
 
	return "SUCESS"
func play_slash_animation():
	var collision_shape = Globals.hovered_unit.get_node("CollisionArea/CollisionShape2D")  # Replace with your actual node path
	var shape_size = collision_shape.shape.extents * 2  # For RectangleShape2D and CapsuleShape2D
	var pos = Globals.hovered_unit.global_position + shape_size / 2
	Utils.play_animation_at_position($SlashAnimation,"slash",pos) 
func attack():
	super.attack()
	Globals.hovered_unit.get_node("HealthComponent").hit(1) 
	remain_actions -=1
	play_slash_animation()

func process_action():
	
#	print("CALLED")
#	super.try_attack()
	try_attack()
# toggle_action_screen()
#func play_attack_animation(attacked_entity):
#	$SlashAnimation.z_index = 1000
#	#	slash_animation.position = Globals.hovered_unit.position #.ZERO  # Center of the unit
#	var collision_shape = attacked_entity.get_node("CollisionArea/CollisionShape2D")  # Replace with your actual node path
#	var shape_size = collision_shape.shape.extents * 2  # For RectangleShape2D and CapsuleShape2D
#	$SlashAnimation.global_position = Globals.hovered_unit.global_position + shape_size / 2
#	# Calculate the angle to face Globals.hovered_unit
#	if Globals.hovered_unit:
#		var dir_to_hovered = (Globals.hovered_unit.position - position).normalized()
#		var angle_to_hovered = dir_to_hovered.angle()
#		$SlashAnimation.rotation = angle_to_hovered
#
#	$SlashAnimation.play("slash")
