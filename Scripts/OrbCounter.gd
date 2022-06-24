extends MarginContainer

onready var anim_player = $Sprite/AnimationPlayer

func _ready() -> void:
	anim_player.play("empty")
