extends Path2D

onready var follow = $PathFollow2D
onready var drone = $PathFollow2D/Drone

func _process(delta):
	if drone:
		follow.set_offset(follow.get_offset() + 6 * delta)
