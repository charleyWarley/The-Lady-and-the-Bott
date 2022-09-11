extends Node2D

const SOUNDS = {
	"collected": preload("res://audio/sfx/cardPickup2.wav")
}

export(String) onready var title
export(String) onready var description
onready var sprite = $Sprite
onready var sfx = $sfx
onready var anim_player = $AnimationPlayer

func _on_Area2D_body_entered(body):
	if body.name != "lady": return
	$Area2D.set_deferred("monitoring", false)
	$Area2D.set_deferred("monitorable", false)
	print("you found a ", title, " card!")
	Global.cards.append(title)
	print(Global.cards)
	play_anim("collected")
	play_snd("collected")

func _ready():
	match title:
		"": 
			description = "wild card"
			sprite.frame = 0
		"habik": 
			description = "rain or snow"
			sprite.frame = 1
		"brhih": 
			description = "fire"
			sprite.frame = 2
		"batmon": 
			description = "building or house (can't be used alone)"
			sprite.frame = 3
		"khodrham": 
			description = "ally (can't be used alone)"
			sprite.frame = 4

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


