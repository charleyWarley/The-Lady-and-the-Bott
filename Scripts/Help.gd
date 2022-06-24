extends Control

onready var restart = $Buttons/Restart
onready var quit = $Buttons/Quit

func _ready() -> void:
	restart.on_click()

func _process(_delta) -> void:
	if visible:
		if Input.is_action_just_released("bud_down"):
			if restart.click:
				restart.cancel()
				quit.on_click()
		elif Input.is_action_just_released("bud_up"):
			if quit.click:
				quit.cancel()
				restart.on_click()
		elif Input.is_action_just_released("ui_accept"):
			if restart.click:
				get_tree().reload_current_scene()
			elif quit.click:
				get_tree().change_scene("res://World/Environment/Levels/Menus/TitleScreen.tscn")
