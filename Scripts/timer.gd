extends Node2D

onready var label = $time
onready var timer = $Timer
var timerStarted = false


func _process(_delta):
	if Global.moveType == Global.moveTypes.MARIO:
		if !timerStarted:
			set_visible(true)
			timerStarted = true
			if timer.is_paused(): timer.set_paused(false)
			else: timer.start()
	else: 
		timer.set_paused(true)
		set_visible(false)
	label.set_text(str(int(timer.get_time_left())))


func _on_Timer_timeout(): timer.set_wait_time(300.0)
