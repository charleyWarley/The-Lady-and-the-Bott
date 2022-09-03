extends Area2D

var strength = 350


func _on_bounceSpot_body_entered(body):
	if body.name == "lady": 
		body.bounceForce.y += Vector2.UP.y * strength


func _on_bounceSpot_body_exited(body):
	if body.name == "lady": 
		print("bounced")
		body.bounceForce.y = 0
