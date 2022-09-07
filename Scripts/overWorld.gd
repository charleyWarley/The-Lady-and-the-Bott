extends Node


func _ready(): 
	Global.set_moveType(Global.moveTypes.TOP)
	Global.lady.position = $startPosition.position 
	Global.lady.play_anim("top_idle_down", "")
