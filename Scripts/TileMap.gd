extends TileMap


func _on_VisibilityNotifier2D_screen_entered():
	pass
	#visible = true


func _on_VisibilityNotifier2D_screen_exited():
	pass
	#visible = false

func _ready():
	set_visible(true)
