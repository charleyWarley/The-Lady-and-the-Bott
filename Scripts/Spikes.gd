extends Area2D

onready var anim_player = $AnimationPlayer
var isPowered = true
var damage = 1
var power = -180

func _ready():
	add_to_group("hazards")
	anim_player.play("on")
