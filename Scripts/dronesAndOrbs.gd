extends Node2D

var canGrab = false


func _on_tutorialArea_body_entered(body):
	if body.name == "saviya": 
		$Label.visible = true
		$Timer.start()


func _on_Timer_timeout():
	$Label.set_text("grab the drone \nto disable it")
	canGrab = true

func _process(_delta):
	if canGrab and Input.is_action_just_released("grab"): queue_free()
