extends Area2D

var isPowered = true

func _ready():
	add_to_group("spikes")
	$AnimationPlayer.play("on")

func _on_Spikes_body_entered(body):
	if !isPowered:
		return
	match body.name:
		"saviya":
			body.isDead = true
		"alizea":
			body.power += 1
			isPowered = false
			$AnimationPlayer.play("off")
