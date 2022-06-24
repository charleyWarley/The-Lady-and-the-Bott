extends RigidBody2D

const JUMP_BUFFER : float = 0.4

var velocity : Vector2

var timePressedJump : float = 0.0
var timeLeftGround : float = 0.0

enum speeds {
	WALK = 2
	RUN = 3
}

const SOUNDS = {
	"walk": preload("res://audio/walksound.wav"),
	"jump0": preload("res://audio/jump0.wav"),
	"jump1": preload("res://audio/jump1.wav"),
	"jump2": preload("res://audio/jump2.wav")
}

const JUMP_POWER_BOX : int = -80
const JUMP_POWER_ONE : int = -200
const JUMP_POWER_TWO : int = -150
const BOX_SPEED : int = 1
const BOX_DRAG : float= 0.3

var budSpeed : int = speeds.WALK
var budDragGround : float = 0.85
var budDragAir : float = 0.95

var canDoubleJump := false
var wasGrounded := false
var isFlipped := true
var isRevealed := false
var isFull := false
var isMet := false 
var isEmpty := true
var isGrounded := false

var sparks : int = 0
var power : int = 0
var hit : int = 0
var jumps : int = 0
var doubleJumps : int = 0

export(PackedScene) onready var spark
export(NodePath) onready var boxAnimation = get_node(boxAnimation)
export(NodePath) onready var buddyAnimation = get_node(buddyAnimation)
export(NodePath) onready var ray = get_node(ray)
export(PackedScene) onready var fire
export(NodePath) onready var sfx = get_node(sfx)
onready var collisionShape = $alizeaCollision
onready var sprite = collisionShape.get_node("Sprite")


func _ready() -> void:
	collisionShape.set_visible(true)
	collisionShape.set_disabled(true)
	add_to_group("boxes")
	add_to_group("hitable")
	add_to_group("buddy")
	play_anim("box1")


func _process(_delta) -> void:
	Global.jumps = doubleJumps
	if jumps >= 100:
		power -= 1
		jumps = 0
		

func _physics_process(delta) -> void:
	if get_colliding_bodies() and ray.get_collider(): isGrounded = true
	elif !ray.get_collider(): isGrounded = false
	if isGrounded and !wasGrounded: doubleJumps = 0
	check_y()
	var move = check_direction()
	var speed
	var drag
	if !isMet: 
		speed = BOX_SPEED
		drag = BOX_DRAG #velocity += move * BOX_SPEED - BOX_DRAG * Vector2(velocity.x, 0)
	else:
		if Input.is_action_just_pressed("ali_down"): make_spark()
		speed = budSpeed
		if isGrounded: drag = budDragGround
		else: drag = budDragAir
		velocity += move * speed
		if velocity.x > -2 and velocity.x < 2: velocity.x = 0
		elif velocity.x > 12: velocity.x = 12
		elif velocity.x < -12: velocity.x = -12
		var targetVelocity = Vector2(check_x(drag, delta), velocity.y)
		velocity = velocity.linear_interpolate(targetVelocity, 0.1)
	apply_central_impulse(velocity)
	#velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false)

	if move.x > 0.0 and !isFlipped:  flip()
	elif move.x < 0.0 and isFlipped: flip()
	
	anim_check(move)
	wasGrounded = isGrounded


func make_spark() -> void:
	if power == 0: return
	var newSpark : Node2D = spark.instance()
	get_parent().add_child(newSpark)
	newSpark.position = position
	newSpark.get_child(0).set_emitting(true)
	sparks += 1
	if sparks == 2: 
		power -= 1
		sparks = 0
	if power < 0: power = 0


func check_x(drag, delta) -> float:
	velocity.x *= pow(1 - drag, delta * 10)
	return velocity.x


func walk_snd():
	play_snd("walk")


func jump() -> void:
	power_check()
	timeLeftGround = get_cur_time()
	if !isEmpty:
		if !canDoubleJump:
			velocity.y = JUMP_POWER_ONE
			play_snd("jump1")
			jumps += 2
			Global.jumps = jumps
			emit()
			doubleJumps = 0
		elif doubleJumps <= 8:
			velocity.y = JUMP_POWER_TWO
			play_snd("jump2")
			jumps += 1
			doubleJumps += 1
	else:
		if !canDoubleJump:
			velocity.y = JUMP_POWER_BOX
			play_snd("jump0")


func get_cur_time() -> float:
	var time = OS.get_ticks_msec() / 1000.0
	return time


func check_direction() -> Vector2:
	var move = Vector2()
	if Input.is_action_pressed("ali_left"): move.x -= 1
	elif Input.is_action_pressed("ali_right"): move.x += 1
	move = move.normalized()
	return move


func check_y() -> void:
	if isMet and isRevealed:
		var pressed_jump = Input.is_action_just_pressed("ali_up")
		if pressed_jump:
			if isGrounded: canDoubleJump = false
			else: canDoubleJump = true
			jump()
		else: velocity.y = 0
		rotation = 0
		#rotation = lerp(rotation, 0, 0.25)
	if isGrounded and velocity.y > 0: velocity.y = 0

func flip() -> void:
	if !isMet: return
	else:
		sprite.flip_h = !sprite.flip_h
		isFlipped = !isFlipped


func power_check() -> void:
	if power == 0:
		isEmpty = true
		isFull = false
	elif power > 0:
		isEmpty = false
		if power < 20: isFull = false
		elif power >= 20:
			power = 20
			isFull = true


func play_anim(newAnimation) -> void:
	var animPlayer
	if !isMet: animPlayer = boxAnimation
	else: animPlayer = buddyAnimation
	match animPlayer.current_animation: 
		newAnimation: return
		"reveal": return
	animPlayer.play(newAnimation)

func anim_check(move) -> void:
	if !isEmpty:
		if !isMet:
			if hit == 0: play_anim("box2")
			elif hit == 1:
				play_anim("box2_hit1") 
				hit += 1
			elif hit == 2: 
				play_anim("box2_hit2")
				hit += 1
		else:
			if !isRevealed: return
			elif isGrounded:
				if move == Vector2(): play_anim("idle2")
				else: play_anim("walk2")
			elif velocity.y < 0: play_anim("jump")
			elif velocity.y > 0: play_anim("fall")
	else:
		if !isMet:
			if hit == 0: play_anim("box1")
			elif hit == 1: 
				play_anim("box1_hit1")
				#hit += 1
			elif hit == 2: 
				play_anim("box1_hit2")
				#hit += 1
		else:
			if !isRevealed: return
			elif isGrounded:
				if move == Vector2(): play_anim("idle")
				else: play_anim("walk")
			elif velocity.y < 0: play_anim("jump")
			elif velocity.y > 0: play_anim("fall")

	if hit >= 3 and !isMet:
		isMet = true
		play_anim("reveal")


func play_snd(snd) -> void:
	if !SOUNDS.has(snd): return
	sfx.stream = SOUNDS[snd]
	sfx.play()


func emit() -> void:
	var newFire = fire.instance()
	get_parent().add_child(newFire)
	newFire.position = position + Vector2(0, 5)
	newFire.emitting = !newFire.emitting


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name != "reveal": return
	isRevealed = true
	#remove_from_group("boxes")
	$boxCollision.queue_free()
