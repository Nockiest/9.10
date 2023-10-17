extends Node

var movement_sounds = [preload("res://music/grass_step.wav"), preload("res://music/gravel_step.wav")]

func play_random_sound():
	var random_index = randi_range(0, len(movement_sounds) -1) 
	#var random_sound = movement_sounds[random_index]
	$AudioStreamPlayer.stream =  movement_sounds[random_index]
	$AudioStreamPlayer.play()
	

#func play_random_sound():
#	var children_count = get_child_count()
#
#	# Check if there are any child nodes
#	if children_count > 0:
#		var random_index = randi() % children_count
#		var random_sound_player = get_child(random_index)
#		print("PLAYING SOUND ", random_sound_player)
#		# Check if the randomly selected child is an AudioStreamPlayer
##		if random_sound_player is AudioStreamPlayer:
#		random_sound_player.play()
##		else:
##			print("Child at index", random_index, "is not an AudioStreamPlayer.")
#	else:
#		print("No child nodes to play.")
#
func process(state) -> void:
	if state == owner.state.Moving:
		if !$AudioStreamPlayer.playing:
			play_random_sound()
#		var should_play_sounds = true
#		for child in get_children():
#			if child.is_playing: ##potential mistake
#				print(child, "IS PLAYING")
#				should_play_sounds = false
#				break
#		if should_play_sounds:
#			play_random_sound()
