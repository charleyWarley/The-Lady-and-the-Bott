extends Area2D

onready var anim_player = $AnimationPlayer
var isPowered = true
var damage = 1
var power = -180

func _ready():
	add_to_group("spikes")
	anim_player.play("on")

func _on_Spikes_body_entered(body):
	if !isPowered:
		return
	match body.name:
		"lady":
			body.emit_signal("damage_taken", damage, Vector2.UP)
			#body.bounceForce.y += power
		"bott":
			isPowered = false
			anim_player.play("off")

