extends Node2D



func _on_VisibilityNotifier2D_screen_entered():
	print(name, " is shown")
	set_visible(true)


func _on_VisibilityNotifier2D_screen_exited():
	set_visible(false)
	print(name, " is hidden")
