extends Control
export(NodePath) onready var music = get_node(music) as AudioStreamPlayer
export(NodePath) onready var single = get_node(single) as ViewportContainer
export(NodePath) onready var view = get_node(view) as Viewport
export(NodePath) onready var mainMenu = get_node(mainMenu) as Node2D
export(NodePath) onready var pauseMenu = get_node(pauseMenu) as Node2D
export(NodePath) onready var map = get_node(map) as Node2D

export(PackedScene) onready var multi
export(PackedScene) onready var level1

onready var camera = view.get_node("camera")
onready var orbCase = get_node("OrbCase")
onready var jumpGauge = get_node("jumpGauge")
onready var logo = view.get_node("logo")

var lady
var bott

#restart the level when finished (for unfinished game only)
func _on_level_exited(_body) -> void:
	get_tree().reload_current_scene()

#executed when the player clicks start game
func _on_game_started(players) -> void:
	music.play()
	orbCase.set_visible(true)
	jumpGauge.set_visible(true)
	
	##if the game is on an android phone, show the virtual controller
	if OS.get_name() == "Android": $virtualController.set_visible(true)
	
	#check for single player or multiplayer
	match players:
		#set up the single-player environment
		"single":
			Global.players = ("single")
			
			#clear the title screen
			mainMenu.queue_free()
			logo.queue_free()
			
			#load the first level
			var level = level1.instance()
			view.add_child(level)
			level.get_node("levelExit").connect("body_exited", self, "_on_level_exited")
			camera._set_current(true)
			
			#set the camera to follow the lady
			lady = level.get_node("saviya")
			camera.target = lady
			
			
			#lady.connect("camera_shake", camera, "_on_camera_shake")
			
			#set the virtual controller to lady's controls(default)
			set_controller(lady)
		
		#set up the multi-player environment
		"multi":
			Global.players = ("multi")
			
			#clear the title screen and default environment
			single.queue_free()
			
			#load the new viewport container for the muntiplayer environment
			var multiView = multi.instance()
			add_child(multiView)
			
			#load the level
			var level = get_node("multiView/HBoxContainer/view1/World")
			
			#set the lady as saviya
			lady = level.get_node("saviya")
			camera = multiView.camera1
			
			#the controller should be set here, maybe
			
	#connect the camera_shake signal from the lady node, run the _on_camera_shake function on the camera node
	lady.connect("camera_shake", camera, "_on_camera_shake")


func _input(event) -> void:
	#register a screen touch as ui_accept
	if event is InputEventScreenTouch:
		if event.pressed: Input.action_press("ui_accept")
		else: Input.action_release("ui_accept")
	
	#otherwise, if the remaining actions aren't pause or help, ignore the rest
	elif !event.is_action("pause") and !event.is_action("help"):
		return
	
	#if pause or help are pressed
	if event.pressed: 
		#if the level is paused
		if get_tree().is_paused():
			#if the event pause was released, close the pause menu
			if event.is_action("pause"): pauseMenu.move(Vector2(819, 1278))
			#otherwise, close the map
			else: map.move(Vector2(0, 1278))
			#unpause the level
			get_tree().set_pause(false)
		
		#if the level isn't paused
		else:
			#if the pause event was pressed, open the pause menu
			if event.is_action("pause"): pauseMenu.move(Vector2(819, 430))
			#otherwise, open the map
			else: map.move(Vector2.ZERO)
			#pause the level
			get_tree().set_pause(true)


func _ready() -> void:
	#hide the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	#connect the game_started event to the _on_game_started function
	mainMenu.connect("game_started", self, "_on_game_started")


func _process(_delta) -> void:
	#check for controller input change
	if $virtualController/savControls.is_pressed():  set_controller(lady)
	elif $virtualController/aliControls.is_pressed(): set_controller(bott)


func set_controller(character) -> void:
	#make an array of the buttons
	var buttons = [$virtualController/left,
	$virtualController/right,
	$virtualController/up,
	$virtualController/down]
	
	#for each button in the array, change the action tag prefix
	for button in buttons: 
		match character:
			lady: button.action = "sav_" + button.name
			bott: button.action = "ali_" + button.name
