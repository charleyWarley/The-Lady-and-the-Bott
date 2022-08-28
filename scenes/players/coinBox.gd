extends Area2D

export(PackedScene) onready var prize

func _on_Area2D_body_entered(body):
	if body.name == "lady": 
		if body.velocity.y > -120: return
		var newPrize = prize.instance()
		get_parent().set_deferred("prize", newPrize)
		queue_free()
