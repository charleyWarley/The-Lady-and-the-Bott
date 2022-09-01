extends Area2D

var canExit := false
export(NodePath) onready var normalCamera = get_node(normalCamera) as Camera2D
export(NodePath) onready var exit = get_node(exit) as Position2D
var player

func _on_bonusExit_body_entered(body): 
	if body.name == "lady": 
		player = body
		canExit = true
func _on_bonusExit_body_exited(body): if body.name == "lady": canExit = false



func _process(_delta): if canExit and Input.is_action_just_pressed("sav_right"): 
	if normalCamera == null: normalCamera = get_viewport().get_camera()
	player.position = exit.position
	normalCamera.position.x = player.position.x
	normalCamera.make_current()
