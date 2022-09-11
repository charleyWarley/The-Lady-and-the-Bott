extends Breakable
class_name Crate

const SOUNDS = {
	"hit": preload("res://audio/sfx/bonk.wav")
}

var health = 3

onready var sprite = $Sprite
onready var sfx = $sfx
onready var collision = $CollisionShape2D
onready var pickupTimer = $Timer

func _on_VisibilityNotifier2D_screen_entered(): self.set_visible(true)
func _on_VisibilityNotifier2D_screen_exited(): self.set_visible(false)


func _ready():
	add_to_group("boxes")
	add_to_group("hitable")
	add_to_group("grabable")
	self.set_visible(false)
	sprite.frame = 0


func take_damage(power : int, rightForce : bool):
	play_snd("hit")
	var force = 70 * power
	if rightForce: force = -force
	apply_central_impulse(Vector2(force, 0))
	health -= 1
	if health == 2: sprite.frame = 1
	elif health == 1: sprite.frame = 2
	elif health <= 0:
		destroy()

	
func destroy():
	if contents != null: 
		print("item dropped")
		var newItem = contents.instance()
		get_parent().add_child(newItem)
		newItem.set_position(position)
		print(newItem.name, "  ", newItem.position, " from ", self.position)
	queue_free()
	


func play_snd(snd) -> void:
	if SOUNDS.has(snd):
		if !sfx.is_playing():
			sfx.stream = SOUNDS[snd]
			sfx.play()



