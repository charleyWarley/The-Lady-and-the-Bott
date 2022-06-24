extends HBoxContainer

export(NodePath) onready var view1 = get_node(view1) as Viewport
export(NodePath) onready var view2 = get_node(view2) as Viewport
export(NodePath) onready var camera1 = get_node(camera1) as Camera2D
export(NodePath) onready var camera2 = get_node(camera2) as Camera2D
export(NodePath) onready var world = get_node(world) as Node2D

func _ready():
	view2.world_2d = view1.world_2d
	var parallax_copy = world.get_node("setting/ParallaxBackground").duplicate()
	parallax_copy.set_custom_viewport(view2)
	world.add_child(parallax_copy)
	parallax_copy.scale *= 0.2
	var player1 = world.get_node("saviya")
	var player2 = world.get_node("alizea")
	camera1.target = player1
	camera2.target = player2
	print(player1.name)
	print(player2.name)
