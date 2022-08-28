extends Node2D


func _ready():
	self.set_visible(false)


func move(target):
	var move_tween = $tween
	move_tween.interpolate_property(self, "position", position, target, 2, Tween.TRANS_QUINT, Tween.EASE_OUT)
	move_tween.start()


func _on_VisibilityNotifier2D_screen_entered(): self.set_visible(true)


func _on_VisibilityNotifier2D_screen_exited(): self.set_visible(false)



