extends Area2D

signal switch_flipped(isPoweredOn)

onready var sfx = $sfx
onready var anim_player = $AnimationPlayer
var isPoweredOn = false
var canInteract = false

const SOUNDS = {
	"flipped": preload("res://audio/sfx/hitObject.wav")
}

func _on_Lever_body_entered(body): 
	if body.name != "lady": return
	canInteract = true

func _on_Lever_body_exited(body):
	if body.name != "lady": return
	canInteract = false


func ready():
	play_anim("start")


func _process(_delta):
	if !canInteract: return
	check_powered()


func play_snd(snd) -> void:
	if SOUNDS.has(snd):
		if !sfx.is_playing():
			sfx.stream = SOUNDS[snd]
			sfx.play()


func check_powered():
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name != "lady": return
		if Input.is_action_just_pressed("interact"):
			isPoweredOn = !isPoweredOn
			emit_signal("switch_flipped", isPoweredOn)
			play_snd("flipped")
			if isPoweredOn: play_anim("on")
			else: play_anim("off")


func play_anim(anim):
	if anim_player.current_animation == anim: return
	anim_player.play(anim)




