extends Area2D

export(String, FILE, ".tscn") var worldScene
var open = false
onready var anim_player = $AnimationPlayer

func _ready() -> void:
	anim_player.play("close")

func _process(delta) -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == "PushBox":
			if Global.orbs > 60:
				open = true
			else:
				print("locked")
		elif body.name == "Player" and open:
			if Input.is_action_pressed("action"):
				get_tree().change_scene(worldScene)
		
		if open:
			anim_player.play("open")
		if !open:
			anim_player.play("close")
