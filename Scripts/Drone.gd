extends RigidBody2D

onready var anim_player = $AnimationPlayer
onready var sfx = $sfx/sfx
onready var particle = $Particles2D
onready var sprite = $Sprite
onready var leftRay = $leftRay
onready var rightRay = $rightRay
onready var path = get_parent()

const SOUNDS = {
	"zap1":
preload("res://audio/elec.wav")
}

var hit = 0
var isDead = false
var canDie = false
var isFlipped = false
var isLeftFree = false
var isRightFree = false
var isGrabbed = false

func _ready():
	play_anim("idle")
	add_to_group("drones")
	add_to_group("hitable")


func _process(_delta):
	if isDead or isGrabbed or canDie:
		return
	rotation = 0
	if !canDie:
		particle.visible = false
		play_anim("idle")
	isLeftFree = !check_ray(leftRay)
	isRightFree = !check_ray(rightRay)
	if isLeftFree and !isRightFree: isFlipped = true
	if isRightFree and !isLeftFree: isFlipped = false
	check_flip()


func _physics_process(_delta):
	if isDead or isGrabbed or canDie: return
	if isFlipped: 
		position.x -= 0.5
	else: 
		position.x += 0.5


func check_ray(ray) -> bool:
	var collider = ray.get_collider()
	var isCollider
	if !collider: isCollider = false
	else: isCollider = true
	if !collider: 
		canDie = false
		return isCollider
	if collider.name == "saviya" and !canDie:
		collider.isDead = true
	else: 
		if collider.name == "alizea":
			if !collider.isRevealed:
						return isCollider
			if Input.is_action_just_pressed("ali_down") and !canDie:
				canDie = true
				play_anim("dead")
				play_snd("zap1")
				collider.power_check()
				particle.visible = true
	return isCollider

func check_flip():
	if isFlipped:
		sprite.flip_h = true
	else:
		sprite.flip_h = false


func play_anim(anim):
	if anim_player.current_animation == anim: return
	anim_player.play(anim)

func play_snd(snd):
	if !SOUNDS.has(snd): return
	sfx.stream = SOUNDS[snd]
	sfx.play()


func _on_Timer_timeout():
	canDie = false
