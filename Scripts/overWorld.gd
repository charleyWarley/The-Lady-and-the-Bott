extends Node


func _ready(): 
	Global.set_moveType(Global.moveTypes.TOP)
	if Global.lady: 
		Global.lady.position = $startPosition.position 
