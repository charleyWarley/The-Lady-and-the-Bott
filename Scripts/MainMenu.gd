extends Node2D

signal game_started(players)

const SOUNDS = {
	"switchUI": preload("res://audio/sfx/switchUISound.wav"),
	"selectUI": preload("res://audio/sfx/selectUISound.wav"),
	"cancelUI": preload("res://audio/sfx/cancelSound.mp3")
	}

var player_edit := ""

export(NodePath) onready var startMenu = get_node(startMenu) as Node2D
export(NodePath) onready var newGame = get_node(newGame) as Button
export(NodePath) onready var loadGame = get_node(loadGame) as Button
export(NodePath) onready var options = get_node(options) as Button
export(NodePath) onready var inputMenu = get_node(inputMenu) as Node2D
export(NodePath) onready var bott = get_node(bott) as Button
export(NodePath) onready var lady = get_node(lady) as Button
export(NodePath) onready var w = get_node(w) as Button
export(NodePath) onready var a = get_node(a) as Button
export(NodePath) onready var s = get_node(s) as Button
export(NodePath) onready var d = get_node(d) as Button
export(NodePath) onready var n4 = get_node(n4) as Button
export(NodePath) onready var n5 = get_node(n5) as Button
export(NodePath) onready var n6 = get_node(n6) as Button
export(NodePath) onready var n7 = get_node(n7) as Button
export(NodePath) onready var n8 = get_node(n8) as Button
export(NodePath) onready var n9 = get_node(n9) as Button
#export(NodePath) onready var en = get_node(en) as Button
#export(NodePath) onready var de = get_node(de) as Button
#export(NodePath) onready var ja = get_node(ja) as Button
#export(NodePath) onready var ro = get_node(ro) as Button

export(NodePath) onready var sfx = get_node(sfx)
export(NodePath) onready var sfx2 = get_node(sfx2)

var menu = "main"


func _ready():
	inputMenu.move(Vector2(0, 263))
	startMenu.move(Vector2(62, 145))
	set_button(newGame, newGame)
	

func _process(_delta):
	#check menu inputs
	match menu:
		"main": check_main_menu()
		"options": check_options_menu()

func check_options_menu():
	return

#func check_lang_menu():
#	if Input.is_action_just_released("ui_down"):
#		play_snd("switchUI")
#		if en.is_pressed():
#			set_button(en, de)
#		elif de.is_pressed():
#			set_button(de, ja)
#		elif ja.is_pressed():
#			set_button(ja, ro)
#		else: en.set_pressed(true)
#	elif Input.is_action_just_released("ui_up"):
#		play_snd("switchUI")
#		if ro.is_pressed():
#			set_button(ro, ja)
#		elif ja.is_pressed():
#			set_button(ja, de)
#		elif de.is_pressed():
#			set_button(de, en)
#		else: en.set_pressed(true)
#	elif Input.is_action_just_released("ui_accept"):
#		play_snd("selectUI")
#		if en.is_pressed():
#			en.set_pressed(false)
#			TranslationServer.set_locale("en")
#		elif de.is_pressed():
#			de.set_pressed(false)
#			TranslationServer.set_locale("de")
#		elif ja.is_pressed():
#			ja.set_pressed(false)
#			TranslationServer.set_locale("ja")
#		elif ro.is_pressed():
#			ro.set_pressed(false)
#			TranslationServer.set_locale("ro")
#		else:
#			print("idk what to do ")
#		set_menu(options_buttons, startMenu)
#		menu = "main"
#		newGame.set_pressed(true)

func check_input_menu():
	if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up"): 
		if lady.is_pressed(): set_button(lady, bott)
		if bott.is_pressed(): set_button(bott, lady)
	if Input.is_action_just_pressed("ui_enter"):
		if lady.is_pressed() and $inputOptions/players.is_visible(): 
			player_edit = "lady"
			$inputOptions/players.set_visible(false)
			$inputOptions/menu.set_visible(true)
			
	
func check_main_menu():
	if Input.is_action_just_released("ui_down"):
		play_snd("switchUI")
		if newGame.is_pressed():
			set_button(newGame, loadGame)
		elif loadGame.is_pressed():
			set_button(loadGame, options)
	elif Input.is_action_just_released("ui_up"):
		play_snd("switchUI")
		if options.is_pressed():
			set_button(options, loadGame)
		elif loadGame.is_pressed():
			set_button(loadGame, newGame)
	elif Input.is_action_just_released("ui_accept"):
		play_snd("selectUI")
		if newGame.is_pressed():
			emit_signal("game_started", "single")
			print("newGame started")
		elif loadGame.is_pressed():
			#load_game()
			print("loadGame")
		elif options.is_pressed():
			options.set_pressed(false)
#			en.set_pressed(true)
			menu = "options"
			startMenu.move(Vector2(62, 263))
			inputMenu.move(Vector2(0, 0))
			set_button(bott, lady)

func load_game():
	var file = File.new()
	file.open("user://save_game.dat", File.READ)
	var content = file.get_as_text()
	file.close()
	return content


	
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

