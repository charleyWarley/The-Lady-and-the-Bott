extends Area2D

var strength = -350


func _on_bounceSpot_body_entered(body):
	match body.name:
		"lady": body.bounceForce.y = strength
		"bott": body.bounceForce.y = strength * 3

func _on_bounceSpot_body_exited(body):
	match body.name:
		"lady": body.bounceForce.y = 0
		"bott": body.bounceForce.y = 0
