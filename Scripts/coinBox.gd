extends Area2D



func _on_Area2D_body_entered(body):
	if body.name == "lady": 
		if body.velocity.y > -120: return
		
