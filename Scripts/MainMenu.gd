extends Node2D

signal game_started(players)

export(NodePath) onready var song1 = get_node(song1) as AudioStreamPlayer
export(NodePath) onready var main_buttons = get_node(main_buttons) as Node2D
export(NodePath) onready var single = get_node(single) as Button
export(NodePath) onready var multi = get_node(multi) as Button
export(NodePath) onready var lang = get_node(lang) as Button

export(NodePath) onready var lang_buttons = get_node(lang_buttons) as Node2D
export(NodePath) onready var en = get_node(en) as Button
export(NodePath) onready var de = get_node(de) as Button
export(NodePath) onready var ja = get_node(ja) as Button
export(NodePath) onready var ro = get_node(ro) as Button

var menu = "main"
var isMusicPlaying = false



func _ready() -> void:
	song1.play()
	


func _process(_delta) -> void:
	if Input.is_action_just_pressed("mute"):
		isMusicPlaying = !isMusicPlaying
		mute()
	
	#check menu inputs
	match menu:
		"main": check_main_menu()
		"langs": check_lang_menu()
		

func check_lang_menu():
	if Input.is_action_just_released("ui_down"):
		if en.is_pressed():
			switch_pressed(en, de)
		elif de.is_pressed():
			switch_pressed(de, ja)
		elif ja.is_pressed():
			switch_pressed(ja, ro)
		else: en.set_pressed(true)
	elif Input.is_action_just_released("ui_up"):
		if ro.is_pressed():
			switch_pressed(ro, ja)
		elif ja.is_pressed():
			switch_pressed(ja, de)
		elif de.is_pressed():
			switch_pressed(de, en)
		else: en.set_pressed(true)
	elif Input.is_action_just_released("ui_accept"):
		if en.is_pressed():
			en.set_pressed(false)
			TranslationServer.set_locale("en")
		elif de.is_pressed():
			de.set_pressed(false)
			TranslationServer.set_locale("de")
		elif ja.is_pressed():
			ja.set_pressed(false)
			TranslationServer.set_locale("ja")
		elif ro.is_pressed():
			ro.set_pressed(false)
			TranslationServer.set_locale("ro")
		else:
			print("idk what to do ")
		switch_menu(lang_buttons, main_buttons)
		menu = "main"
		single.set_pressed(true)
		
			
func check_main_menu():
	if Input.is_action_just_released("ui_down"):
		if single.is_pressed():
			switch_pressed(single, multi)
		elif multi.is_pressed():
			switch_pressed(multi, lang)
	elif Input.is_action_just_released("ui_up"):
		if lang.is_pressed():
			switch_pressed(lang, multi)
		elif multi.is_pressed():
			switch_pressed(multi, single)
	elif Input.is_action_just_released("ui_accept"):
		if single.is_pressed():
			emit_signal("game_started", "single")
			print("single started")
		elif multi.is_pressed():
			emit_signal("game_started", "multi")
			print("multi player")
		elif lang.is_pressed():
			lang.set_pressed(false)
			en.set_pressed(true)
			menu = "langs"
			switch_menu(main_buttons, lang_buttons)


#switch the button pressed
func switch_pressed(old, new) -> void:
	old.set_pressed(false)
	new.set_pressed(true)


#switch out the menus
func switch_menu(old, new) -> void:
	old.move(Vector2(190, 1193))
	new.move(Vector2(190, 780))


func mute() -> void:
	if !isMusicPlaying:
		print("unmuted")
		song1.play()
	else:
		print("muted")
		song1.stop()
