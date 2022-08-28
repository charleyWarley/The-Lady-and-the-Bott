extends VBoxContainer

signal musicButton_pressed
signal crtButton_pressed

onready var music = $musicButton
onready var crt = $crtButton


func _input(_event):
	if Input.is_action_just_pressed("pause"):
		music.set_pressed(true)
		crt.set_pressed(false)
		return
	if !get_tree().is_paused(): return
	if Input.is_action_just_pressed("ui_accept"):
		if music.is_pressed(): emit_signal("musicButton_pressed")
		elif crt.is_pressed(): emit_signal("crtButton_pressed")
		var buttons = get_children()
		for button in buttons: button.set_pressed(false)
		return
			
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		if music.is_pressed(): 
			music.set_pressed(false)
			crt.set_pressed(true)
		elif crt.is_pressed():
			crt.set_pressed(false)
			music.set_pressed(true)
