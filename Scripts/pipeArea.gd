extends Area2D

signal pipe_entered

var canEnter = false
var player
export(NodePath) onready var bonusArea = get_node(bonusArea)
export(NodePath) onready var bonusCamera = get_node(bonusCamera) as Camera2D


func _on_pipeArea_body_entered(body):
	if body.name == "lady": 
		player = body
		canEnter = true


func _on_pipeArea_body_exited(_body):
	canEnter = false
	player = null


func _process(_delta):
	if !canEnter: return
	if Input.is_action_just_pressed("sav_down"): 
		player.position = bonusArea.position
		bonusCamera.make_current()
		
