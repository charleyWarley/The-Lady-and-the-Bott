extends Node2D


export(Vector2) var direction

func _on_Area2D_body_entered(body):
	if body.name != "lady": return
	body.emit_signal("gravity_shifted", direction)
	$AnimationPlayer.play("disappear")
