extends Area2D
var startPos = Vector2()

func _on_breakArea_body_entered(body):
	if body.name == "lady":
		if body.velocity.y > -120: return
		Global.orbs += 1
		get_parent().destroy()
