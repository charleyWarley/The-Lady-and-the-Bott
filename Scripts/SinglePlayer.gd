extends Node

onready var world = $Viewports/ViewportContainer1/Viewport1/World
onready var camera = $Viewports/ViewportContainer1/Viewport1/Camera2D

func _ready() -> void:
	camera.target = world.get_node("Player")
	print(camera.target)
 
