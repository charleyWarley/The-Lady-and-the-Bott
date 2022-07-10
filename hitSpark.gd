extends Node2D

var isMoving
var isStarted = false
var direction

func _process(_delta):
	if !isMoving or isStarted: return
	$Tween.interpolate_property(self, "position",
		position, position + Vector2(120, 0) * direction, 1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	isStarted = true
