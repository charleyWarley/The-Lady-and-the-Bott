extends Control

const SONGS = {
	"menuSong": preload("res://audio/song1.wav"),
	"gameSong": preload("res://audio/Ambience1.wav")
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
onready var camera = view.get_node("camera") setget set_camera, get_camera
export(NodePath) onready var HUD = get_node(HUD)

var connected = false
var lady
var bott
var world setget set_world

var isMusicPlaying = false
var canPause = false

#restart the level when finished (for unfinished game only)
func _on_level_exited(_body) -> void: var _exit = get_tree().reload_current_scene()


#executed when the player clicks start game
func _on_game_started(_players) -> void:
	canPause = true
	set_song("gameSong")
	Global.set_deferred("moveType", Global.moveTypes.TOP)
	var elements = HUD.get_children()
	for element in elements:
		element.set_visible(true)
	Global.players = ("single")
	mainMenu.queue_free() #clear the title screen
	set_deferred("world", overWorld)

	
func _on_world_changed(location):
	loading.set_visible(true)
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 2
	var _timer_connect = timer.connect("timeout", self, "clear_loading_screen")
	timer.start()
	var movement
	match location:
		"overWorld": 
			location = overWorld
			movement = Global.moveTypes.TOP
		"levelOne": 
			location = levelOne
			movement = Global.moveTypes.SIDE
		"marioWorld":
			location = marioWorld
			movement = Global.moveTypes.MARIO
	print(location, movement)
	set_deferred("world", location)
	Global.set_deferred("moveType", movement)


func _input(event) -> void:
	if event is InputEventScreenTouch: #register a screen touch as ui_accept
		if event.pressed: Input.action_press("ui_accept")
		else: Input.action_release("ui_accept")
	elif !event.is_action("pause") and !event.is_action("fullscreen") and !event.is_action("mute") and !event.is_action("crt"):
		return
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
		if get_tree().is_paused():
			if event.is_action("pause"):
				unpause()
				return
		else:
			if event.is_action("pause"): 
				pause()
				return
				



func _ready() -> void:
	loading.set_visible(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) #hide the mouse
	set_song("menuSong")
	mainMenu.connect("game_started", self, "_on_game_started") #connect the game_started event to the _on_game_started function
	pauseButtons.connect("musicButton_pressed", self, "mute")
	pauseButtons.connect("crtButton_pressed", self, "set_crtVisibility")


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
	if world != level: 
		if world != null: world.queue_free()
		world = level
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
		camera._set_current(true)
		camera.set_zoom(Vector2(1,1))
	lady = level.get_node("lady") #set the camera to follow the lady
	camera.target = lady
	if !connected: connected = lady.connect("world_changed", self, "_on_world_changed")

func get_camera(): return camera
