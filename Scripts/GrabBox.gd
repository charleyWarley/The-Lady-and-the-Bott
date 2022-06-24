extends Area2D

onready var box = get_parent()

func _physics_process(_delta) -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player":
			if Input.is_action_just_pressed("action"):
				box.grab()
	if Input.is_action_just_released("action"):
s		box.ungrab()
