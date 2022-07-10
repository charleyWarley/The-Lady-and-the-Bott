extends Node2D

var isHitPressed = false
var isGrabPressed = false


func _on_interactionTutorialArea_body_entered(body):
	if body.name == "saviya": 
		$tutorialArea.queue_free()
		$Label.visible = true

func _process(_delta):
	if Input.is_action_just_released("hit") and $Label.visible == true: isHitPressed = true
	if isHitPressed: 
		$Label.set_text("hold S to grab and throw")
		if Input.is_action_just_released("grab"): isGrabPressed = true
		if isGrabPressed: $Label.set_text("collect enough power cells to \nforge energy cores")
