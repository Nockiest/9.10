extends Node

signal cur_player_has_been_changed
signal blue_player_money_changed(value)
signal red_player_money_changed(value)
var red_player_units: int = 3
var blue_player_units: int = 2
var red_player_color: Color = Color("ff0000")
var blue_player_color: Color = Color("0000ff")
var players = ["blue", "red"]
var cur_player = "blue"
var hovered_unit
var placed_unit
var hovered_structure
var action_taking_unit
var attacking_component
var moving_unit
var last_attacker
var can_start_new_attack = true

func update_cur_player():
	cur_player = players[cur_player_index]
	emit_signal("cur_player_has_been_changed") 
 
func end_game(loser):
	print(loser, " lost the game")
	get_tree().change_scene_to_file("res://scenes/screens/EndGameScreen/end_game_screen.tscn")# 
 
var cur_player_index =  0 :
	get:
		return  cur_player_index 
	set(value):
		cur_player_index =  value  % len(players) 
		update_cur_player() 
 
# settings config
var num_towns = 6
var num_rivers = 3
var num_forests = 5
var blue_player = {
	'num_Medics': 0,
	'num_Observers': 1,
	'num_Supply_carts': 1,
	'num_Cannons': 0,
	'num_Musketeers': 2,
	'num_Pikemen':1,
	'num_Shields': 1,
	'num_Knights': 1,
	'num_Commanders': 1,
}

var blue_player_money = 100:
	get:
		return blue_player_money
	set(value):
		blue_player_money = max(0, min(value,100))
		emit_signal("blue_player_money_changed", value)
var red_player_money = 100:
	get:
		return red_player_money
	set(value):
		red_player_money = max(0, min(value,100))
		emit_signal("red_player_money_changed", value)
var red_player = {
	'num_Medics': 0,
	'num_Observers': 1,
	'num_Supply_carts': 1,
	'num_Cannons': 0,
	'num_Musketeers': 2,
	'num_Pikemen':1,
	'num_Shields': 1,
	'num_Knights': 1,
	'num_Commanders': 1,
}
var money_per_turn = 10
var city_turn_income = 10
var min_town_spacing_distance = 200
 
## game stats
#num_turns =  0  
#num_attacks =  0, 0 
#killed_units = 0
#enemies_killed = 0
#money_spent = 0
#shots_fired = 0
 
