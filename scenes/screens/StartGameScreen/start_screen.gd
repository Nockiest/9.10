extends Control
 
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_game_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/Battleground.tscn") 


func _on_settings_btn_pressed():
	show_and_hide($SettingsScreen, $MainButtons)
	#get_tree().change_scene_to_file("res://scenes/screens/SettingsScreen/settings_screen.tscn") 
	
func show_and_hide(show, hide):
	show.show()
	hide.hide()


func _on_back_to_start_screen_btn_button_up():
	show_and_hide($MainButtons, $SettingsScreen)
