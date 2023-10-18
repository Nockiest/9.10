## move th emovement component to the center and do all the calculations from there
## move the unit only after checking, that the localtion is valid
## move only after checking that the line to the position is valid
## coor the line to see, which place is valid to move to
class_name MovementComponent
extends Node2D
signal remain_movement_changed( )
signal ran_out_of_movement()
var base_movement_range:int:
	set(new_range):
		base_movement_range = new_range
		remain_distance = base_movement_range 
@onready var global_start_turn_position :Vector2 =  owner.global_position -owner.size/2
@onready var buy_areas = get_tree().get_nodes_in_group("buy_areas")
#@export var movement_sounds:Array[AudioStream] = []
var remain_distance  = base_movement_range:
	set(new_distance):
		remain_distance =new_distance 
		emit_signal("remain_movement_changed"  )
		if new_distance < 0 :
			abort_movement()
			remain_distance =  base_movement_range
			owner.update_stats_bar()
			emit_signal("ran_out_of_movement") 
	get:
		return remain_distance
var movement_modifiers:Dictionary = {
	"base_modifier": 1,
	"on_road": 0,
	"in_forrest": 0,
} 
var current_movement_modifier #=  calculate_total_movement_modifier()
var on_bridge:bool = false 
var on_river:bool= false
var mouse_pos_offset: Vector2 #= Vector2(0,0)
enum state {
	Idle,
	Moving,
	Placed
}
var current_state:state = state.Idle
 
func _ready():
	await owner._ready()
	call_deferred_thread_group("calculate_total_movement_modifier")
	#$RayCast2D.global_position = Utils.get_collision_shape_center(owner.get_node("CollisionArea"))
	
func enter_movement_state():
	if not check_can_turn_movement_on():
		exit_movement_state() 
		return 
	$Line2D.clear_points()
	$AudioStreamPlayer.play()
	Globals.moving_unit = owner
	Globals.action_taking_unit = null
	print("TURNING MOVEMENT LOOK ON")
 
	toggle_moving_appearance("on")
	current_state = state.Moving
	$SelectSound.play()
#	$MovementSoundPlayer.should_play_sounds = true
func exit_movement_state():
	owner.get_node("UnitStatsBar").visible = false
	$Line2D.clear_points()
	$AudioStreamPlayer.stop()
	current_state = state.Idle
	toggle_moving_appearance("off")
	if Globals.moving_unit == owner:
		Globals.moving_unit = null
 
func exit_placed_state():
	print("EXITING PLAcED STATE",  owner.center, to_global(owner.center), owner.position, owner.get_node("Center").global_position)
	current_state = state.Idle
	global_start_turn_position = owner.global_position#center
#	owner.global_position = global_start_turn_position#Vector2(global_start_turn_position.x + mouse_pos_offset.x, global_start_turn_position.y + mouse_pos_offset.y) 
func enter_placed_state():
	current_state = state.Placed
	owner.is_newly_bought = false

func toggle_moving_appearance(toggle):
	if toggle == "on":
		owner.outline_node.modulate = Color("black")
		owner.get_node("ColorRect").modulate = Color("gray")
	elif toggle == "off":
		owner.outline_node.modulate = Color("white")
		owner.get_node("ColorRect").modulate = Color(owner.color)
	else:
		print("ARGUMENT ", toggle)
		assert(false, "TOGGLE MOVEMENT COLOR GOT BAD ARGUMENT" )

func calculate_total_movement_modifier():
	current_movement_modifier = Utils.sum_dict_values(movement_modifiers)
	owner.update_stats_bar() #PRO4 TO NEFUNGUJE??
 
func process(_delta):
#	$MovementSoundPlayer.process(current_state)
	calculate_total_movement_modifier()
	if current_state == state.Placed: 
		owner.position = get_global_mouse_position() - owner.size / 2
		print("OWNER POS ", owner.position)
		if Input.is_action_just_pressed("left_click"):
			process_unit_placement()
	elif current_state == state.Moving:
		move()#call_deferred_thread_group("move"  ) 
		if Input.is_action_just_pressed("right_click"):
			abort_movement()
		elif Input.is_action_just_pressed("left_click"):
#			set_new_start_turn_point()
			set_owner_position($NewPosition.global_position-owner.size/2)
			exit_movement_state()
	elif current_state == state.Idle:
		if Input.is_action_just_pressed("left_click"):
			enter_movement_state()

func get_area_at_position():
	pass

func check_can_turn_movement_on():
	if Globals.hovered_unit != get_parent():
#		print("CASE 2")
		return false
	elif Globals.action_taking_unit != get_parent() and Globals.action_taking_unit != null:
#		print("CASE 3")
		return false
	elif Globals.action_taking_unit != null:
#		print("CASE 4")
		return false
	elif Globals.placed_unit != null:
#		print("case 5")
		return false
	return true

func _input(event):
	if current_state == state.Idle:
		return
	if event is InputEventMouseMotion:
		# Get the mouse position in global coordinates
		var mouse_position = get_global_mouse_position()

		# Get all areas overlapping with the mouse position
		var overlapping_areas = mouse_position.get_overlapping_areas( )

		# Check if there are any overlapping areas
		if overlapping_areas.size() > 0:
			print("Areas at mouse position:", mouse_position)

			# Iterate through each overlapping area
			for area in overlapping_areas:
				print(" - Area Name:", area.name)  # Assuming your areas have unique names
				# Add more information about the area if needed

		else:
			print("No areas at mouse position:", mouse_position)

func _on_collision_area_area_exited(_area): ## zde je možné, že když rychle vystoupíz jednoho leasa do druhého bude se myslet že není v lese 
	var still_on_bridge = false
	var still_on_road = false
	var still_on_river = false
	var still_on_forrest = false
	for overlapping in $CollisionArea.get_overlapping_areas():
		if overlapping.get_parent().get_parent() is Forrest:
			still_on_forrest = true #$movement_comp.movement_modifiers["in_forrest"] = 0.5
		elif overlapping.get_parent() is Road:
			still_on_road = true #$movement_comp.movement_modifiers["on_road"] = -0.5
		elif overlapping.get_parent() is Bridge:
			still_on_bridge = true
		elif overlapping.get_parent() is RiverSegment:
			still_on_river = true
	print("AREA EXITED",	$movement_comp.movement_modifiers)
	if not still_on_road:
		$movement_comp.movement_modifiers["on_road"] = 0
	if not still_on_forrest:
		$movement_comp.movement_modifiers["in_forrest"] = 0
	$movement_comp.on_bridge = still_on_bridge
	$movement_comp.on_river = still_on_river
	$movement_comp.calculate_total_movement_modifier()

#func _on_collision_area_entered(area):
#	if $movement_comp.current_state !=   $movement_comp.state.Moving:
#		return
##	if Globals.placed_unit != self and  Globals.placed_unit != null :
##		print("IGNORE AREA ENTERED")
##		return
#	if area is UnitsMainCollisionArea:
#		$movement_comp.abort_movement()
#
#	for overlapping in $CollisionArea.get_overlapping_areas():
#		if overlapping.get_parent().get_parent() is Forrest:
#			$movement_comp.movement_modifiers["in_forrest"] = 0.5
#			$movement_comp.current_movement_modifier = Utils.sum_dict_values($movement_comp.movement_modifiers)
#		elif overlapping.get_parent() is Road:
#			$movement_comp.movement_modifiers["on_road"] = -0.5
#			$movement_comp.current_movement_modifier = Utils.sum_dict_values($movement_comp.movement_modifiers)
#		elif overlapping.get_parent() is Bridge:
#			$movement_comp.on_bridge = true
#		elif overlapping.get_parent() is RiverSegment and !$movement_comp.on_bridge and  Globals.placed_unit != self and   $movement_comp.movement_modifiers["on_road"] == 0:
#			print("ENETERED RIVER")
#			$movement_comp.abort_movement()##$movement_comp.exit_movement_state()
##		use_$movement_comp_abort()
#		if  overlapping.get_parent() is RiverSegment:
#			$movement_comp.on_river = true
#		$movement_comp.calculate_total_movement_modifier()
#	print("NEW MODIFIERS ", $movement_comp.movement_modifiers)
#	#print("MOVEMENT MODIFIERS ", Utils.sum_dict_values($movement_comp.movement_modifiers) , $movement_comp.movement_modifiers)
#
func move( ):
	owner.get_node("UnitStatsBar").visible = true
#	print("CALLED",   Globals.moving_unit != owner, on_river and not on_bridge and movement_modifiers["on_road"] == 0)
	if Globals.moving_unit != owner:
		return
	if on_river and not on_bridge and movement_modifiers["on_road"] == 0:
		abort_movement()
	## distance just traveled is the distanc ebetween current center and the mousepos with accounted offset that gives the current center
	var mouse_pos = get_global_mouse_position()
	$Line2D.add_point(to_local(mouse_pos))
	$RayCast2D.position =to_local($NewPosition.global_position)  #$Line2D.get_point_position( $Line2D.get_point_count() -1) 
	$RayCast2D.target_position = to_local( mouse_pos )
	$RayCast2D.force_raycast_update()
#	print($RayCast2D.position,$RayCast2D.target_position  , "X")
#	print(to_local( mouse_pos))
	if $RayCast2D.is_colliding():
	# There is an obstruction between the units
		print($RayCast2D.get_collider(),$RayCast2D.get_collider().get_parent(),"  ", $RayCast2D.get_collision_point())
	var new_position =  mouse_pos  #  - mouse_pos_offset  
	var old_position = $NewPosition.global_position#owner.global_position
	var distance_just_traveled = floor( new_position.distance_to(old_position) ) * current_movement_modifier  
#	print( new_position.distance_to(old_position) , "DISTANCE",mouse_pos_offset,  new_position,   old_position)
	remain_distance -= distance_just_traveled
	if remain_distance < 0:
		print(remain_distance, " REM")
		return
	$NewPosition.global_position = new_position
#	print("NEW POS ", position, $Line2D.get_point_count() )
#	set_owner_position(new_position)

#	if floor( new_position.distance_to(old_position) ) <= 1 :
#		distance_just_traveled =  0
#	else:
#	var distance_just_traveled  #last_position.distance_to(mouse_pos )#0
func abort_movement():
	print("CALLED ABORT MOVEMENT ", global_start_turn_position)
	Globals.moving_unit = null
	remain_distance = base_movement_range
	set_owner_position(global_start_turn_position-owner.size/2 )  
	exit_movement_state() 
 
## A very ugly way to deceslect movement
func set_owner_position(new_position):
	$Line2D.clear_points()
	owner.global_position = new_position 
	owner.center = owner.get_node("Center").global_position
	
func process_for_next_turn():
	remain_distance = base_movement_range
	set_new_start_turn_point()  


func  set_new_start_turn_point():
	print("SETTING NEW START TURN POS",global_position)
	global_start_turn_position = owner.global_position + owner.size/2


func process_unit_placement():
	if Globals.hovered_unit != null and Globals.hovered_unit != owner:
		print(Globals.hovered_unit == null, Globals.hovered_unit, "POSITION CANNOT BE SET")
		return
	var in_valid_buy_area = false
	## check wheter it is being placed inside the buy bar
	for buy_area in buy_areas:
#			print("COLORS",Color(buy_area.team) , color, buy_area.units_inside)
		if Color(buy_area.team) != owner.color:
			continue  
		if owner not in buy_area.units_inside:
			continue
		print("IN BUY AREA")
		in_valid_buy_area = true
	## check wheter it is placed in and of the occupied cities
	for town in get_tree().get_nodes_in_group("towns"):
		if town.team_alligiance == null:
			continue
		if Color(town.team_alligiance)!= owner.color:
			continue
		if self in town.units_inside:
			print("UNIT IS INSIDE OF AN OCCUPIED CITY")
			in_valid_buy_area = true
	
	for river_segment in get_tree().get_nodes_in_group("river_segments"):
#			print(river_segment.get_node("Area2D"), river_segment.get_node("Area2D").get_overlapping_areas ( ))
		for area in  river_segment.get_node("Area2D").get_overlapping_areas ( ):
			if area == owner.get_node("CollisionArea"):
				print(area, " OVERLAPS")
				in_valid_buy_area = false
				break

	if in_valid_buy_area:
		print(Globals.hovered_unit,"CAN PLACE A UNIT")
		owner.is_newly_bought = false
		Globals.placed_unit = null
		exit_placed_state()
		return
	print(Globals.hovered_unit, in_valid_buy_area, "POSITION CANNOT BE SET")
 

	if Input.is_action_just_pressed("right_click"): 
		print("ABORTING BUYING AND GIVING MONEY BACK")
		owner.queue_free()






#	var mouse_pos = get_global_mouse_position()
#	var x_distance = mouse_pos.x - global_position.x
#	var y_distance = mouse_pos.y - global_position.y
#	$RayCast2D.global_position = mouse_pos
#	mouse_pos_offset = Vector2(x_distance, y_distance)#global_position.distance_to(get_global_mouse_position())
#	print("MOUSE OFFSET ", mouse_pos_offset, mouse_pos, global_position)
