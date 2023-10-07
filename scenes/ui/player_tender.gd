extends Control
 
var team:String  
var prev_units = null
var sorted_units:Dictionary = {}

func _ready():
	var index = get_index()
	if index == 0:
		$ColorRect.color = Color("red")
		team = "red"
		Globals.connect("red_player_money_changed", update_tender )
	elif index == 1:
		$ColorRect.color = Color("blue")
		team = "blue"
		Globals.connect("blue_player_money_changed", update_tender)
	else:
		print("This node is not the first or second child of its parent.")
 

func _process(_delta):
	update_tender()
	
func sort_units(units):
	sorted_units = {}
	for unit in units:
		var unit_type = unit.unit_name  # get_class()
		if sorted_units == null:
			sorted_units[unit_type] = 1
		elif unit_type in sorted_units:
			sorted_units[unit_type] += 1
		else:
			sorted_units[unit_type] = 1

func update_tender():
#	var units = get_tree().get_nodes_in_group("living_units")
	var same_color_units = get_tree().get_nodes_in_group(str(Color(team)))
	var current_money =  Globals.red_player_money if team == "red" else   Globals.blue_player_money
	if prev_units == same_color_units  :
		prev_units = same_color_units
		return
	prev_units = same_color_units
#	print("called")
	print(Globals.blue_player_money, "BLUE PLAYER MONEY ON UPDATE ", team)
	if team == "blue":  
		$ColorRect/VScrollBar/VBoxContainer/Money/Label.text = str(Globals.blue_player_money)
	elif team =="red":
		$ColorRect/VScrollBar/VBoxContainer/Money/Label.text = str(Globals.red_player_money)
	else:
		print_debug("something wrong with rendering money ", team)
 
	if same_color_units:
#		print(same_color_units)
		sort_units(same_color_units)
 
	var vbox = $ColorRect/VScrollBar/VBoxContainer
	for child in vbox.get_children():
	# If the child's name begins with "UnitCount", delete it
		if not child.name.begins_with("Money"):
			child.queue_free()

# For each count in unit_counts, create a new Label and add it to the VBoxContainer
	for key in sorted_units.keys():
		var label = Label.new()
		label.name = "UnitCount" + key
		label.text = key + ": " + str(sorted_units[key])
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(label)
