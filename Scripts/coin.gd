extends Area2D

signal collected

onready var animPlayer = $AnimationPlayer

func _on_coin_body_entered(body):
	if body.name == "lady": animPlayer.play("collected")

func _on_collected():
	animPlayer.play("collected")

func _ready():
	var _collected = connect("collected", self, "_on_collected")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "collected": 
		Global.orbs += 6
		queue_free()
	
