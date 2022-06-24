extends Area2D

export(String, FILE, ".tscn") var worldScene

onready var anim_player = $AnimationPlayer

func _ready() -> void:
	anim_player.play("open")

func _process(_delta) -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player":
			if Input.is_action_just_released("action"):
				get_tree().change_scene(worldScene)
