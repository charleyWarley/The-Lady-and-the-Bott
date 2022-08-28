extends Node2D

var isHitPressed = false
var isGrabPressed = false


func _on_interactionTutorialArea_body_entered(body):
	if body.name == "saviya": 
		$tutorialArea.queue_free()
		$Label.visible = true


func _ready():
	$Label.set_visible(false)

func _process(_delta):
	if Input.is_action_just_released("hit") and $Label.visible == true: isHitPressed = true
	if isHitPressed: 
		$Label.set_text("hold NUMPAD-9 to grab and throw")
		if Input.is_action_just_released("use_ability"): isGrabPressed = true
		if isGrabPressed: $Label.set_text("collect enough power cells to \nforge energy cores")
