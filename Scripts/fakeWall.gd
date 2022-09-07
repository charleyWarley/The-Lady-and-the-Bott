extends StaticBody2D

func _ready():
	add_to_group("hitable")
	set_visible(false)

func _on_VisibilityNotifier2D_screen_entered():
	self.set_visible(true)


func _on_VisibilityNotifier2D_screen_exited():
	self.set_visible(false)


func take_damage(_power : int, _rightForce : bool):
	queue_free()
