tool
extends Light2D

func _process(delta):
	update()
	

func _draw():
	draw_arc(Vector2.ZERO, 350, 0, TAU, 36, Color.white, 2, true)
