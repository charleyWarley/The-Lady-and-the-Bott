extends Node2D

const SOUNDS = {
	"collected": preload("res://audio/sfx/swipeSound.wav")
}

export(String) onready var title
export(String) onready var description
onready var sfx = $sfx
onready var anim_player = $AnimationPlayer

func _on_Area2D_body_entered(body):
	if body.name != "lady": return
	$Area2D.set_deferred("monitoring", false)
	$Area2D.set_deferred("monitorable", false)
	print("you found a ", title, " card!")
	play_anim("collected")
	play_snd("collected")


func play_snd(snd) -> void:
	if SOUNDS.has(snd):
		if !sfx.is_playing():
			sfx.stream = SOUNDS[snd]
			sfx.play()


func play_anim(anim) -> void:
	if anim_player.current_animation == anim:
		return
	else:
		anim_player.play(anim)


