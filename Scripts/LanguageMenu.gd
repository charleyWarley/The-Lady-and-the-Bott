extends Control

onready var buttons = $HBoxContainer/TextureRect/HBoxContainer/Buttons
onready var english = buttons.get_node("EnglishButton")
onready var german = buttons.get_node("GermanButton")
onready var japanese = buttons.get_node("JapaneseButton")

func _ready() -> void:
	english.on_click()

func _process(_delta) -> void:
	if Input.is_action_just_released("bud_down"):
		if english.click:
			english.cancel()
			german.on_click()
		elif german.click:
			german.cancel()
			japanese.on_click()
	elif Input.is_action_just_released("bud_up"):
		if japanese.click:
			japanese.cancel()
			german.on_click()
		elif german.click:
			german.cancel()
			english.on_click()
	elif Input.is_action_just_released("ui_accept"):
		if english.click:
			TranslationServer.set_locale("en")
			english.cancel()
			get_tree().change_scene("res://World/Environment/Levels/Menus/TitleScreen.tscn")
		elif german.click:
			TranslationServer.set_locale("de")
			german.cancel()
			get_tree().change_scene("res://World/Environment/Levels/Menus/TitleScreen.tscn")
		elif japanese.click:
			TranslationServer.set_locale("ja")
			japanese.cancel()
			get_tree().change_scene("res://World/Environment/Levels/Menus/TitleScreen.tscn")
