extends Selectable

	
func _physics_process(_delta):
	if hit == 1:
		play_anim("hit2")
	if hit >= 2 and hit != 100:
		hit = 100
		play_anim("hit3")
		
	
func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
