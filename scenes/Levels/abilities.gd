extends Node2D

var slide = 0

func _on_tutorialArea_body_entered(body):
	if body.name == "saviya": 
		$Timer.start()
		$Label.visible = true


func _on_Timer_timeout():
	slide += 1
	if slide == 1: 
		$Timer.start()
		$Label.set_text("into abilities")
	elif slide == 2:
		queue_free()
