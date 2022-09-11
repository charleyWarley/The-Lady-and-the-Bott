extends Node2D

var direction
var speed

func _ready():
	randomize()
	direction = randi() % 2
	if direction == 0: direction = -1
	if direction == 1: direction = 1
	speed = ((float(randi() % 9)) + 1 / (float(randi() % 9)) + 1)
	set_scale(Vector2(rand_range(1.0, 3.0), rand_range(1.0, 3.0)))
	
func _process(delta):
	position.x += 0.1 * direction
