extends Area2D

export(String, FILE, ".tscn") var worldScene

func _physics_process(_delta) -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player":
			get_tree().change_scene(worldScene)
