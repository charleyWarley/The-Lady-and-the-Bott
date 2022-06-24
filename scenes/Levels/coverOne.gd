extends Node2D



func _on_showOne_body_entered(body):
	pass # Replace with function body.


func _on_hideOne_body_entered(body):
	if body.name != "saviya" and body.name != "alizea":
		return
	set_visible(false)


func _ready():
	set_visible(true)
