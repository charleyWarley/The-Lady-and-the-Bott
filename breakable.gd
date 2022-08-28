extends RigidBody2D
class_name Breakable

export(PackedScene) var contents

func _ready():
	add_to_group("breakable")
	add_to_group("hitable")
