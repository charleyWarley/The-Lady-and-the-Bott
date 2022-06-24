extends Node2D

var isLeftPressed = false
var isRightPressed = false
var isJumpPressed = false
var isRunPressed = false

func _process(_delta):
	if Input.is_action_just_released("sav_left"): isLeftPressed = true
	elif Input.is_action_just_released("sav_right"): isRightPressed = true
	if isLeftPressed and isRightPressed:
		$Label.set_text("hold SHIFT to run")
		if Input.is_action_just_released("run") and !isRunPressed: isRunPressed = true
		if isRunPressed:
			$Label.set_text("use W to jump")
			if Input.is_action_just_released("sav_up"): isJumpPressed = true
			if isJumpPressed: queue_free()



