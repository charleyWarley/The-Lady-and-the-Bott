extends Control

const SONGS = {
	"menuSong": preload("res://audio/music/4-channel-loop1.wav"),
	"gameSong": preload("res://audio/music/ambience/Ambience1.wav")
}

export(NodePath) onready var music = get_node(music) as AudioStreamPlayer
export(NodePath) onready var single = get_node(single) as ViewportContainer

export(NodePath) onready var mainMenu = get_node(mainMenu) as Node2D
export(NodePath) onready var pauseMenu = get_node(pauseMenu) as Node2D
export(NodePath) onready var pauseButtons = get_node(pauseButtons) as VBoxContainer
export(NodePath) onready var loading = get_node(loading) as TextureRect
export(NodePath) onready var crt = get_node(crt) as ColorRect

export(PackedScene) onready var multi
export(PackedScene) onready var overWorld
export(PackedScene) onready var levelOne
export(PackedScene) onready var marioWorld

onready var view = single.get_node("view")
onready var camera = view.get_node("normalCamera") setget set_camera, get_camera
export(NodePath) onready var HUD = get_node(HUD)

var connected = false
var lady = preload("res://scenes/players/lady.tscn")
var world setget set_world

var isMusicPlaying = false
var canPause = false
var firstWorld setget set_firstWorld
var wasReset = false

func set_firstWorld(location):
	var movement
	match location:
		"overWorld": 
			location = overWorld
			movement = Global.moveTypes.TOP
			camera.maxLimit = Vector2(1900, 700)
			camera.minLimit = Vector2(-150, -150)
		"levelOne": 
			location = levelOne
			movement = Global.moveTypes.SIDE
			camera.minLimit = Vector2(0, 0)
			camera.maxLimit = Vector2(850, 950)
		"marioWorld":
			location = marioWorld
			movement = Global.moveTypes.MARIO
			camera.maxLimit = Vector2(3200, 150)
			camera.minLimit = Vector2(-150, -500)
	set_deferred("world", location)
	Global.set_deferred("moveType", movement)

#restart the level when finished (for unfinished game only)
func _on_level_exited(_body) -> void: reset_game()

func change_HUD_visibility():
	var elements = HUD.get_children()
	for element in elements:
		element.set_visible(!element.visible)
	
#executed when the player clicks start game
func _on_game_started(_players) -> void:
	change_HUD_visibility()
	canPause = true
	set_song("gameSong")
	Global.set_deferred("moveType", Global.moveTypes.TOP)
	Global.players = ("single")
	mainMenu.queue_free() #clear the title screen
	set_deferred("firstWorld", "overWorld")


func _on_world_changed(location):
	#camera.loading.set_visible(true)
	var movement
	match location:
		"overWorld": 
			location = overWorld
			movement = Global.moveTypes.TOP
			camera.maxLimit = Vector2(1900, 700)
			camera.minLimit = Vector2(-150, -150)
		"levelOne": 
			location = levelOne
			movement = Global.moveTypes.SIDE
			camera.maxLimit = Vector2(1000000, 100000)
			camera.minLimit = Vector2(-10000, -100000)
		"marioWorld":
			location = marioWorld
			movement = Global.moveTypes.MARIO
			camera.maxLimit = Vector2(3200, 150)
			camera.minLimit = Vector2(-150, -500)
	set_deferred("world", location)
	Global.set_deferred("moveType", movement)


func _input(event) -> void:
	if not event is InputEventKey: return
	if event.pressed:
		if event.is_action("fullscreen"): 
			OS.window_fullscreen = !OS.window_fullscreen
			return
		if event.is_action("crt"):
			print("crt visibility changed")
			set_crtVisibility()
			return
		elif event.is_action("mute"): 
			mute()
			return
		elif event.is_action("graphics"):
			change_graphics()
			
			return
		if get_tree().is_paused():
			if event.is_action("pause"):
				unpause()
				return
		else:
			if event.is_action("pause"): 
				pause()
				return

func change_graphics():
	match Global.graphicStyle:
		"8": Global.graphicStyle = "32"
		"32": Global.graphicStyle = "8"

func reset_game() -> void: 
	unpause()
	return
	Global.camera.target = null
	canPause = false
	wasReset = get_tree().reload_current_scene()
	


func _ready() -> void:
	change_HUD_visibility()
	loading.set_visible(false)
	mainMenu.set_menu(mainMenu.inputMenu, mainMenu.startMenu)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) #hide the mouse
	set_song("menuSong")
	mainMenu.connect("game_started", self, "_on_game_started") #connect the game_started event to the _on_game_started function
	pauseButtons.connect("musicButton_pressed", self, "mute")
	pauseButtons.connect("crtButton_pressed", self, "set_crtVisibility")
	pauseButtons.connect("quitButton_pressed", self, "reset_game")

func _process(_delta) -> void: 
	if wasReset: 
		wasReset = false
		mainMenu.set_menu(mainMenu.options_buttons, mainMenu.main_buttons)
	if !camera.target: camera.target = Global.lady


func pause() -> void:
	if !canPause: return
	pauseMenu.move(Vector2(126, 88))
	get_tree().set_pause(true)


func unpause() -> void:
	pauseMenu.move(Vector2(126, -128))
	get_tree().set_pause(false)


func mute() -> void:
	isMusicPlaying = !isMusicPlaying
	if !isMusicPlaying:
		print("unmuted")
		music.play()
	else:
		print("muted")
		music.stop()


func clear_loading_screen(): loading.set_visible(false)


func set_crtVisibility():
	if crt.visible == true: crt.set_visible(false)
	else: crt.set_visible(true)


func set_world(newLevel):
	var level = newLevel.instance() #load the first level
	if !Global.lady: 
		Global.lady = lady.instance() 
		Global.lady.connect("world_changed", self, "_on_world_changed")
	if world != level: 
		if world != null: 
			world.remove_child(Global.lady)
			world.queue_free()
		world = level
		world.add_child(Global.lady)
		view.add_child(level)
	set_camera(level)


func set_song(newSong):
	music.stop()
	if SONGS.has(newSong):
		if !music.is_playing():
			music.stream = SONGS[newSong]
			music.play()


func set_camera(level):
	if level.name != "superMarioBros":
		camera.make_current()
		Global.camera = camera
		camera.set_zoom(Vector2(1,1))
	#set the camera to follow the lady
	camera.target = Global.lady


func get_camera(): return camera
