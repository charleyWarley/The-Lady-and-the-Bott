extends Breakable
class_name Crate

const SOUNDS = {
	"hit": preload("res://audio/sfx/bonk.wav")
}

var health = 3

onready var sprite = $Sprite
onready var sfx = $sfx

func _on_VisibilityNotifier2D_screen_entered(): self.set_visible(true)
func _on_VisibilityNotifier2D_screen_exited(): self.set_visible(false)


func _ready():
	add_to_group("boxes")
	self.set_visible(false)


func hit(power : int, rightForce : bool):
	play_snd("hit")
	var force = 80
	if rightForce == false: force = -force
	apply_central_impulse(Vector2(force, 0))
	health -= power
	if health == 2: sprite.frame = 1
	elif health == 1: sprite.frame = 2
	elif health <= 0:
		if contents != null: 
			print("item dropped")
			drop_item()
		queue_free()


func drop_item():
	var newItem = contents.instance()
	get_parent().add_child(newItem)
	newItem.set_position(position)
	print(newItem.name, "  ", newItem.position, " from ", self.position)


func play_snd(snd) -> void:
	if SOUNDS.has(snd):
		if !sfx.is_playing():
			sfx.stream = SOUNDS[snd]
			sfx.play()



