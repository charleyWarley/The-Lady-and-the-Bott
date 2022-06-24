extends Area2D

signal power_transferred
onready var door = get_parent()
onready var anim_player = $AnimationPlayer
var off = true

func ready() -> void:
	play_anim("start")

func _process(_delta) -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		match body.name: 
			"saviya":
				if Input.is_action_just_pressed("grab"):
					off = !off
					emit_signal("power_transferred")
					if !off:
						play_anim("on")
						door.isOpening = true
						print("on")
					else:
						print("off")
						play_anim("off")
						if door.isOpen: 
							door.play_anim("close")
							door.isOpen = false

func play_anim(anim) -> void:
	if anim_player.current_animation == anim: return
	anim_player.play(anim)
