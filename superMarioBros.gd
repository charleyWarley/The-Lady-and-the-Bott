extends Node


func _ready():
	Global.set_moveType(Global.moveTypes.MARIO)


func _on_pipeArea_pipe_entered():
	print("pipe entered")

