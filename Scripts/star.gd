extends Node2D

signal star_collected(ability)

const SOUNDS = {
	"collected": preload("res://audio/sfx/cancelSound.mp3")
}

onready var animPlayer = $AnimationPlayer
onready var sfx = $sfx
export(String) var ability


func _on_Area2D_body_entered(body):
	if body.name != "lady": return
	match ability:
		"reach": Abilities.canReach = true
		"hang": Abilities.canHang = true
		"stomp": Abilities.canStomp = true
	Global.orbs += 20
	play_anim("star_collected")
	play_snd("collected")
	emit_signal("star_collected", ability)


func play_snd(snd) -> void:
	if SOUNDS.has(snd):
		if !sfx.is_playing():
			sfx.stream = SOUNDS[snd]
			sfx.play()


func play_anim(anim):
	if animPlayer.current_animation == anim: return
	animPlayer.play(anim)
