extends KinematicBody2D

var isWalking = false
var speed = 15
var direction = Vector2(-1, 0)
var t = 0.3
var attack = 1
var isLeftFree = false
var isRightFree = false
const GRAVITY = 28
onready var leftRay = $leftRay
onready var rightRay = $rightRay
onready var sprite = $Sprite
var isFlipped = true

func _ready():
	self.set_visible(false)


func _process(_delta):
	if !visible: return
	rotation = 0
	isLeftFree = !check_ray(leftRay)
	isRightFree = !check_ray(rightRay)
	if isLeftFree and !isRightFree: isFlipped = true
	if isRightFree and !isLeftFree: isFlipped = false
	check_flip()

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
		if collider.name == "lady": 
			if collision.normal.y != 1: 
				var dir = collision.normal
				collider.emit_signal("damage_taken", attack, dir)
			elif collision.normal.y == 1: print("killed")


func check_ray(ray: RayCast2D) -> bool:
	var hasCollider = ray.is_colliding()
	if !hasCollider: return hasCollider
	var collider = ray.get_collider()
	print("collision detected")
	hasCollider = true
	if collider.name == "lady":
		collider.emit_signal("damage_taken", 1, direction)
	return hasCollider


func check_flip():
	if Abilities.isGrabbing: return
	sprite.flip_h = !sprite.flip_h


func disable_areas():
	$CollisionShape2D.queue_free()
	$CollisionShape2D2.queue_free()

func _on_killArea_body_entered(body):
	if body.name == "lady": $AnimationPlayer.play("dead")




func _on_VisibilityNotifier2D_viewport_entered(_viewport):
	self.set_visible(true)


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	self.set_visible(false)
