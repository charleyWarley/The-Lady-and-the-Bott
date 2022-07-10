extends Node2D

onready var anim_player = $Sprite/AnimationPlayer
var orbs = 0

func _ready() -> void:
	play_anim("empty")


func _process(_delta) -> void:
	#if the orbs in the case already match the global number of orbs, ignore the rest of the code
	if orbs == Global.orbs: return
	
	#otherwise, do this:
	orbs = Global.orbs
	$Label.set_text(str(orbs))
	match Global.orbs:
		0: play_anim("empty")
		1: play_anim("one")
		5: play_anim("two")
		10: play_anim("three")
		20: play_anim("four")
		50: play_anim("five")
		80: play_anim("six")
		100: play_anim("full")


func play_anim(anim) -> void:
	if anim_player.current_animation == anim: return
	anim_player.play(anim)
