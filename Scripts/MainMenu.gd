extends Node2D

signal game_started(players)

const SOUNDS = {
	"switchUI": preload("res://audio/switchUISound.wav"),
	"selectUI": preload("res://audio/selectUISound.wav"),
	"cancelUI": preload("res://audio/cancelSound.mp3")
	}

export(NodePath) onready var main_buttons = get_node(main_buttons) as Node2D
export(NodePath) onready var single = get_node(single) as Button
export(NodePath) onready var multi = get_node(multi) as Button
export(NodePath) onready var lang = get_node(lang) as Button

export(NodePath) onready var lang_buttons = get_node(lang_buttons) as Node2D
export(NodePath) onready var en = get_node(en) as Button
export(NodePath) onready var de = get_node(de) as Button
export(NodePath) onready var ja = get_node(ja) as Button
export(NodePath) onready var ro = get_node(ro) as Button

export(NodePath) onready var sfx = get_node(sfx)
export(NodePath) onready var sfx2 = get_node(sfx2)

var menu = "main"


func _ready():
	set_menu(lang_buttons, main_buttons)
	set_button(single, single)


func _process(_delta):
	#check menu inputs
	match menu:
		"main": check_main_menu()
		"langs": check_lang_menu()


func check_lang_menu():
	if Input.is_action_just_released("ui_down"):
		play_snd("switchUI")
		if en.is_pressed():
			set_button(en, de)
		elif de.is_pressed():
			set_button(de, ja)
		elif ja.is_pressed():
			set_button(ja, ro)
		else: en.set_pressed(true)
	elif Input.is_action_just_released("ui_up"):
		play_snd("switchUI")
		if ro.is_pressed():
			set_button(ro, ja)
		elif ja.is_pressed():
			set_button(ja, de)
		elif de.is_pressed():
			set_button(de, en)
		else: en.set_pressed(true)
	elif Input.is_action_just_released("ui_accept"):
		play_snd("selectUI")
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
		set_menu(lang_buttons, main_buttons)
		menu = "main"
		single.set_pressed(true)


func check_main_menu():
	if Input.is_action_just_released("ui_down"):
		play_snd("switchUI")
		if single.is_pressed():
			set_button(single, multi)
		elif multi.is_pressed():
			set_button(multi, lang)
	elif Input.is_action_just_released("ui_up"):
		play_snd("switchUI")
		if lang.is_pressed():
			set_button(lang, multi)
		elif multi.is_pressed():
			set_button(multi, single)
	elif Input.is_action_just_released("ui_accept"):
		play_snd("selectUI")
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
			set_menu(main_buttons, lang_buttons)


func play_snd(snd) -> void:
	if SOUNDS.has(snd):
		if !sfx.is_playing():
			sfx.stream = SOUNDS[snd]
			sfx.play()
		else:
			sfx2.stream = SOUNDS[snd]
			sfx2.play()


func set_button(old, new) -> void:
	old.set_pressed(false)
	new.set_pressed(true)


func set_menu(old, new) -> void:
	old.move(Vector2(62, 263))
	new.move(Vector2(62, 145))
