extends Area2D

onready var anim_player = $AnimationPlayer
var isPowered = true

func _ready():
	add_to_group("spikes")
	anim_player.play("on")

func _on_Spikes_body_entered(body):
	if !isPowered:
		return
	match body.name:
		"lady":
			body.isDamaged = true
		"bott":
			isPowered = false
			anim_player.play("off")
