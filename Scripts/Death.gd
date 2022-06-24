extends Control

onready var restart = $HBoxContainer/TextureRect/Buttons/Restart

func _ready():
	restart.on_click()

func _process(delta):
	if visible:
		if Input.is_action_just_released("ui_accept"):
			get_tree().reload_current_scene()
