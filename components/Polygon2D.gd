extends Node2D

var draw_range = 100

func _ready():
	visible = true
#	position = get_parent().get_parent().position

func _proces():
	queue_redraw() 
func _draw():
	z_index = 0
	draw_circle(Vector2.ZERO, draw_range, Color("black"))
