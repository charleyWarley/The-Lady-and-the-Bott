extends RigidBody2D


onready var anim_player = $AnimationPlayer
onready var sfx = $sfx/sfx
onready var particle = $Particles2D
onready var sprite = $sprite
onready var leftRay = $leftRay
onready var rightRay = $rightRay

const SOUNDS = {
	"zap1":
preload("res://audio/elec.wav")
}

var target
var health = 1
var isDead = false
var canDie = false
var isFlipped = false
var isLeftFree = false
var isRightFree = false
var isGrabbed = false
var direction = Vector2(-1, 0)
var isAlerted = false
var speed = 0.5

func _on_Timer_timeout(): canDie = false
func _on_VisibilityNotifier2D_screen_entered(): self.set_visible(true)
func _on_VisibilityNotifier2D_screen_exited(): self.set_visible(false)


func _ready():
	play_anim("idle")
	add_to_group("enemies")
	add_to_group("hitable")
	set_visible(false)


func _process(_delta):
	rotation = 0
	play_anim("idle")
	isLeftFree = !check_ray(leftRay)
	isRightFree = !check_ray(rightRay)
	if isLeftFree and !isRightFree: isFlipped = true
	if isRightFree and !isLeftFree: isFlipped = false
	check_flip()


func _physics_process(_delta):
	if isDead or isGrabbed or canDie: return
	
	if !target:
		if isFlipped: direction.x = -1
		else: direction.x = 1
	else:
		direction.x = -abs(position.direction_to(target.position).x)
	position.x += speed * direction.x
	
func hit(power: int, _rightForce: bool):
	health -= power
	if health <= 0: queue_free()


func check_ray(ray) -> bool:
	var collider = ray.get_collider()
	var isCollider
	if !collider: isCollider = false
	else: isCollider = true
	if !collider: 
		canDie = false
		return isCollider
	if collider.name == "lady" and !canDie:
		collider.emit_signal("damage_taken", 1, direction)
	else: 
		if collider.name == "bott":
			if !collider.isRevealed:
						return isCollider
			if Input.is_action_just_pressed("ali_down") and !canDie:
				canDie = true
				play_anim("dead")
				play_snd("zap1")
				collider.power_check()
				particle.set_emitting(true)
	return isCollider

func _on_enemy_alerted(player):
	isAlerted = true
	target = player

func _on_LOS_broken():
	isAlerted = false
	target = null
	
func check_flip():
	if Abilities.isGrabbing: return
	sprite.flip_h = !sprite.flip_h
	

func play_anim(anim):
	if anim_player.current_animation == anim: return
	anim_player.play(anim)


func play_snd(snd):
	if !SOUNDS.has(snd): return
	sfx.stream = SOUNDS[snd]
	sfx.play()
