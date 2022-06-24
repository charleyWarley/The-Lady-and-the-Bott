extends Area2D

signal powered_on
signal powered_off

onready var anim_player = $AnimationPlayer
var isPoweredOn = false

func ready():
	play_anim("start")

func _process(_delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name != "saviya": return
		if Input.is_action_just_pressed("grab"):
			isPoweredOn = !isPoweredOn
			if isPoweredOn:
				emit_signal("powered_on")
				play_anim("on")
				print("on")
			else:
				print("isPoweredOn")
				emit_signal("powered_off")
				play_anim("off")

func play_anim(anim):
	if anim_player.current_animation == anim: return
	anim_player.play(anim)
