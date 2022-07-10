extends CPUParticles2D
var wasSetOff = false

func _process(_delta):
	if is_emitting():
		wasSetOff = true
	if wasSetOff and !is_emitting():
		queue_free()
