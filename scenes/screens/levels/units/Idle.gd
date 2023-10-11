class_name Idle
extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func handle_input(event):
	print("HANDLING INPUT")


func update(delta: float) -> void:
	print("Updating")
