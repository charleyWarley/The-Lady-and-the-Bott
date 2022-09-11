extends Node2D

onready var tween = $Tween
onready var sprite = $Sprite
var destination = Vector2(0, -180)
var canNotify = false



func _process(_delta):
	if canNotify:
		tween.interpolate_property(self, "position", position, destination, 1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)	
		tween.start()

func _on_Tween_tween_completed(_object, _key):
	queue_free()
