extends Area2D
var health = 6
export(PackedScene) onready var prize

func _on_secretbreakArea_body_entered(body):
	if body.name != "lady" or body.velocity.y > -120: return
	health -= 1
	if health == 0: get_parent().animPlayer.play("collected")
	else: get_parent().animPlayer.play("hit")
	
	
