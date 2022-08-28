extends StaticBody2D

func destroy():
	print("destroyed")
	$AnimationPlayer.play("hit")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "destroyed": queue_free()
	elif anim_name == "hit": $AnimationPlayer.play("destroyed")
