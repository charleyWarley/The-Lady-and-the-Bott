extends Node2D

onready var label = $time
onready var timer = $Timer
var timerStarted = false

func _process(_delta):
	if Global.moveType == Global.moveTypes.MARIO:
		if !timerStarted:
			timer.set_visible(true)
			timerStarted = true
			timer.start()
	else: timer.set_visible(false)
	label.set_text(str(int(timer.get_time_left())))
		


func _on_Timer_timeout():
	queue_free()
