extends Area2D

signal pipe_entered

var canEnter = false
var player

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
		emit_signal("pipe_entered")
		
