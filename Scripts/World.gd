extends Node

export(NodePath) onready var startPosition = get_node(startPosition)

func _ready():
	Global.set_moveType(Global.moveTypes.SIDE)
	if Global.lady: Global.lady.position = startPosition.position
