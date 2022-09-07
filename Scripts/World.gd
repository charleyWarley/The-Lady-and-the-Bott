extends Node

func _ready():
	Global.set_moveType(Global.moveTypes.SIDE)
	Global.lady.position = $startPosition.position
