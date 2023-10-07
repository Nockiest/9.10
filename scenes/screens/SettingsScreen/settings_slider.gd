extends Control

@export var attached_settings_variable = "blue_player_money" 
@export var augmented_dictionary_variable:String = "something"
@export var label_text:String = "Default Label"
@export var slider_range: Array = [0, 100] 
 
func _on_h_slider_value_changed(value):
#	print(attached_settings_variable in Globals)
	if attached_settings_variable in Globals:
		var a = Globals.get(attached_settings_variable)
		print(a is Dictionary, " IS DICTIONARY?", a)
		if a is Dictionary:
			Globals.get(attached_settings_variable)[augmented_dictionary_variable] = value
		else:
			a = value
			Globals.set(attached_settings_variable, a)
			print(Globals.get(attached_settings_variable))

	$VBoxContainer/SliderValueLabel.text = str(round(value))

func _ready():
	print("SLIDER RANGE ", slider_range)
	$VBoxContainer/Label.text = label_text
	$VBoxContainer/HSlider.min_value = slider_range[0]
	$VBoxContainer/HSlider.max_value = slider_range[1]
	var a = Globals.get(attached_settings_variable)
	if attached_settings_variable in Globals and not(a  is Dictionary):
		$VBoxContainer/HSlider.value = Globals.get(attached_settings_variable)
	$VBoxContainer/SliderValueLabel.text = str($VBoxContainer/HSlider.value)
 
 
