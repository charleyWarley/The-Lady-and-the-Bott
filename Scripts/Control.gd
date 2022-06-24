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

var saviya
var alizea


func _on_level_exited(_body) -> void:
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()


func _on_game_started(players) -> void:
	music.play()
	orbCase.set_visible(true)
	jumpGauge.set_visible(true)
	if OS.get_name() == "Android" or OS.has_feature("mobile"): $virtualController.set_visible(true)
	match players:
		"single":
			Global.players = ("single")
			mainMenu.queue_free()
			view.get_node("logo").queue_free()
			var level = level1.instance()
			view.add_child(level)
			level.get_node("levelExit").connect("body_exited", self, "_on_level_exited")
			camera._set_current(true)
			saviya = level.get_node("saviya")
			camera.target = saviya
			saviya.connect("something_hit", camera, "_on_something_hit")
			set_controller(saviya)
		"multi":
			Global.players = ("multi")
			single.queue_free()
			var multiView = multi.instance()
			add_child(multiView)
			var level = get_node("multiView/HBoxContainer/view1/World")
			saviya = level.get_node("saviya")
			saviya.connect("something_hit", multiView.camera1, "_on_something_hit")


func _input(event) -> void:
	if event is InputEventScreenTouch:
		Input.action_release("ui_accept")
	elif !event.is_action("pause") and !event.is_action("help"):
		return
	if event.pressed: 
		if get_tree().is_paused():
			if event.is_action("pause"): pauseMenu.move(Vector2(819, 1278))
			else: map.move(Vector2(0, 1278))
			get_tree().set_pause(false)
		else:
			if event.is_action("pause"): pauseMenu.move(Vector2(819, 430))
			else: map.move(Vector2.ZERO)
			get_tree().set_pause(true)


func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	mainMenu.connect("game_started", self, "_on_game_started")


func _process(_delta) -> void:
	if $virtualController/savControls.is_pressed():  set_controller(saviya)
	elif $virtualController/aliControls.is_pressed(): set_controller(alizea)


func set_controller(character) -> void:
	var buttons = [$virtualController/left,
	$virtualController/right,
	$virtualController/up,
	$virtualController/down]
	for button in buttons: 
		match character:
			saviya: button.action = "sav_" + button.name
			alizea: button.action = "ali_" + button.name
