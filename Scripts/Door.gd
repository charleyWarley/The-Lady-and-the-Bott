extends Area2D

var canOpen = false
var isOpen = false
var isOpening = false

onready var lever = $DoorLever


func _physics_process(_delta) -> void:
	if isOpen: $CollisionShape2D.set_disabled(true)
	else: $CollisionShape2D.set_disabled(false)
	if isOpening: 
		isOpening = false
		isOpen = true
		$door/StaticBody2D/CollisionShape2D.set_disabled(true)
