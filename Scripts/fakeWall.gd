extends Node2D

func _ready():
	$fakeWall.add_to_group("hitable")
	$fakeWall.add_to_group("breakable")
