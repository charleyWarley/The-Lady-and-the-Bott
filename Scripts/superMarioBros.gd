extends Node


func _ready():
	Global.set_moveType(Global.moveTypes.MARIO)
	Global.lady.position = $startPosition.position


func _on_pipeArea_pipe_entered():
	print("pipe entered")

