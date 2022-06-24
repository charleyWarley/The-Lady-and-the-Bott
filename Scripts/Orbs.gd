extends Area2D

var off = false
var wait = 0

const SOUNDS = {
	"break":
preload("res://audio/break.wav")
}

onready var anim_player = $Sprite/AnimationPlayer
onready var sfx = $sfx/sfx


func _ready() -> void:
	add_to_group("orbs")
	play_anim("idle")


func _process(_delta) -> void:
	if !is_monitoring(): return
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if off: return
		match body.name:
			"saviya":
				body.emit_signal("something_hit", 1)
				Global.orbs += 1
				break_it()
			"alizea":
				if body.power < 60:
					body.power += 1
				body.power_check()
				break_it()

func break_it() -> void:
		play_anim("collected")
		play_snd("break")
		off = true


func play_anim(anim) -> void:
	if anim_player.current_animation == anim:
		return
	else:
		anim_player.play(anim)


func play_snd(snd) -> void:
	if SOUNDS.has(snd):
		sfx.stream = SOUNDS[snd]
		sfx.play()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name != "collected": return
	queue_free()
