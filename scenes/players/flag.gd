extends Area2D




func _on_flag_body_entered(body):
	if body.name == "lady": $AnimationPlayer.play("finished")
