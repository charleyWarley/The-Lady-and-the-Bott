extends KinematicBody2D
class_name Enemy

var isWalking = false
var speed = 15
var direction = Vector2(-1, 0)
var t = 0.3
var attack = 1
var isLeftFree = false
var isRightFree = false
const GRAVITY = 28
onready var sprite = $Sprite
var isFlipped = true


func _on_VisibilityNotifier2D_viewport_entered(_viewport): self.set_visible(true)
func _on_VisibilityNotifier2D_viewport_exited(_viewport): self.set_visible(false)


func _ready():
	self.set_visible(false)
	add_to_group("enemies")


func _process(_delta):
	if !visible: return
	rotation = 0
	if isLeftFree and !isRightFree: isFlipped = true
	elif isRightFree and !isLeftFree: isFlipped = false
	if !name.begins_with("goomba"): sprite.set_flip_h(isFlipped)


func _physics_process(_delta):
	var velocity : Vector2
	rotation = 0
	if visible == false: return
	if !is_on_floor(): velocity.y = GRAVITY
	else: velocity.y = 0
	if isFlipped: direction.x = -1
	else: direction.x = 1
	velocity.x = lerp(velocity.x, speed * direction.x, t)
	velocity = move_and_slide(velocity, Vector2.UP)
	check_collisions()


func check_collisions():
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		var collider = collision.collider
		check_blocked(collision.normal.x)
		check_free(collision.normal.x)
		if collider.name == "lady":
			if collision.normal.y != 1: 
				var dir = collision.normal
				collider.emit_signal("damage_taken", attack, dir)


func check_blocked(normal):
	if normal == 1: isLeftFree = false
	elif normal == -1: isRightFree = false


func check_free(normal):
	if normal != -1: isRightFree = true
	if normal != 1: isLeftFree = true


func take_damage():
	$CollisionShape2D.queue_free()
	$AnimationPlayer.play("dead")
