extends Node2D
export(String) var location
var lady
var canOpen = false

func _on_Area2D_body_entered(body):
	print(body.name)
	if body.name == "lady": 
		lady = body
		print("door opened")
		$Sprite/AnimationPlayer.play("open")

func _on_AnimationPlayer_animation_finished(anim_name): 
	if anim_name == "open": lady.emit_signal("world_changed", location)

