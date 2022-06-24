extends Node2D

onready var animPlayer = $AnimationPlayer
var ability

func _on_Area2D_body_entered(body):
	if body.name != "saviya": return
	match ability:
		"reach": body.canReach = true
		"hang": body.canHang = true
	Global.orbs += 20
	play_anim("collected")
		
func play_anim(anim):
	if animPlayer.current_animation == anim: return
	animPlayer.play(anim)

