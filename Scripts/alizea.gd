extends RigidBody2D

const JUMP_BUFFER : float = 0.4

var velocity : Vector2

var timePressedJump : float = 0.0
var timeLeftGround : float = 0.0

enum speeds {
	EMPTY = 0
	WALK = 2
	RUN = 3
	MAX = 6
}

const SOUNDS = {
	"walk": preload("res://audio/sfx/walksound.wav"),
	"jump0": preload("res://audio/sfx/jump0.wav"),
	"jump1": preload("res://audio/sfx/jump1.wav"),
	"jump2": preload("res://audio/sfx/jump2.wav")
}

enum jump_power {
	EMPTY = -250
	FIRST = -300
	SECOND = -200
	}

enum drags {
	TURN = 26
	AIR = 27
	BASIC = 28
	STOP = 100
}

var speed : int = speeds.WALK

var canJump := true
var canDoubleJump := false
var wasGrounded := false
var isFlipped := true
var isRevealed := false
var isFull := false
var isEmpty := true
var isGrounded := false
var isDamaged := false

var sparks : int = 0
var energy : int = 0
var health : int = 0

export(PackedScene) onready var spark
export(NodePath) onready var animPlayer = get_node(animPlayer)
export(NodePath) onready var ray = get_node(ray)
export(PackedScene) onready var fire
export(NodePath) onready var sfx = get_node(sfx)
export(NodePath) onready var sprite = get_node(sprite)

func _ready() -> void:
	add_to_group("buddy")
	play_anim("reveal")


func hit(power : int, rightForce: bool):
	var force = 80
	if rightForce == false: force = -force
	apply_central_impulse(Vector2(force, 0))
	health -= power


func _physics_process(delta) -> void:
	if get_colliding_bodies() and ray.get_collider(): isGrounded = true
	elif !ray.get_collider(): isGrounded = false
	if isGrounded and !wasGrounded: canDoubleJump = true
	if Input.is_action_just_pressed("ali_down"): make_spark()
	var direction = check_direction()
	set_velocity(direction, delta)
	check_flip(direction)
	anim_check(direction)
	wasGrounded = isGrounded


func check_flip(direction):
	if direction.x > 0.0 and !isFlipped:  flip()
	elif direction.x < 0.0 and isFlipped: flip()


func set_velocity(direction, delta):
	velocity += direction.normalized() * speed
	if Global.moveType == Global.moveTypes.SIDE or Global.moveType == Global.moveTypes.MARIO: 
		velocity = Vector2(check_x(delta), check_y())
	elif Global.moveType == Global.moveTypes.TOP: 
		pass #velocity = topdown_movement(drag, delta)
	var targetVelocity = get_target_velocity(direction)
	velocity = velocity.linear_interpolate(targetVelocity, 0.1)
	apply_central_impulse(velocity)


func get_target_velocity(direction) -> Vector2:
	if direction.x == 0:
		if velocity.x > -10 and velocity.x < 10: velocity.x = 0
	return velocity


func check_x(delta) -> float:
	var drag : float
	if isGrounded: 
		if abs(Input.get_axis("ali_left", "ali_right")) <= 0.0: drag = float(drags.STOP) 
		elif sign(Input.get_axis("ali_left", "ali_right")) != sign(velocity.x): 
			drag = float(drags.TURN)
		else: drag = float(drags.BASIC)
	else: drag = float(drags.AIR)
	drag *= 0.01
	velocity.x *= pow(1 - drag, delta * 10)
	if abs(velocity.x) > speeds.MAX: 
		var dir = sign(velocity.x)
		velocity.x = speeds.MAX * dir
	return velocity.x


func check_y() -> float:
	rotation = 0
	if velocity.y < -350: velocity.y = -350
	check_jump()
	var timeDifference = get_cur_time() - timePressedJump
	if isGrounded and velocity.y > 0: velocity.y = 0
	elif !wasGrounded and isGrounded and timeDifference < JUMP_BUFFER:
		check_jump()
	if !Input.is_action_pressed("ali_jump"): velocity.y *= 0.1
	return velocity.y

func check_jump():
	print(canDoubleJump)
	var pressedJump = Input.is_action_just_pressed("ali_jump")
	var releasedJump = Input.is_action_just_released("ali_jump")
	if pressedJump:
		timePressedJump = get_cur_time()
		if isGrounded: 
			if !isDamaged:
				canJump = true
				canDoubleJump = false
				jump()
			else: velocity.y = 0
		elif get_cur_time() - timeLeftGround < JUMP_BUFFER:
			canDoubleJump = true
			jump()
	else: velocity.y = 0

func walk_snd(): play_snd("walk")


func jump() -> void:
	energy_check()
	if canJump or canDoubleJump:
		if !canDoubleJump:
			print("first jump")
			canJump = false
			canDoubleJump = true
			velocity.y = jump_power.FIRST
			play_snd("jump1")
			#emit()
		elif canDoubleJump:
			print("second jump")
			canDoubleJump = false
			velocity.y = jump_power.SECOND
			play_snd("jump2")
	else:
		if !canDoubleJump:
			print("empty jump")
			velocity.y = jump_power.EMPTY
			play_snd("jump0")
	if !isGrounded and wasGrounded: timeLeftGround = get_cur_time()


func make_spark() -> void:
	if energy == 0: return
	var newSpark : Node2D = spark.instance()
	get_parent().add_child(newSpark)
	newSpark.position = position
	newSpark.get_child(0).set_emitting(true)
	sparks += 1
	if sparks == 2: 
		energy -= 1
		sparks = 0
	if energy < 0: energy = 0
	
	
func get_cur_time() -> float:
	var time = OS.get_ticks_msec() / 1000.0
	return time


func check_direction() -> Vector2:
	var move = Vector2()
	if Input.is_action_pressed("ali_left"): move.x = -1
	elif Input.is_action_pressed("ali_right"): move.x = 1
	if Input.is_action_just_released("ali_left") or Input.is_action_just_pressed("ali_right"): move.x = 0
	move = move.normalized()
	return move


func flip() -> void:
	sprite.flip_h = !sprite.flip_h
	isFlipped = !isFlipped


func energy_check() -> void:
	if energy == 0:
		isEmpty = true
		isFull = false
	elif energy > 0:
		isEmpty = false
		if energy < 20: isFull = false
		elif energy >= 20:
			energy = 20
			isFull = true


func anim_check(move) -> void:
	if !isEmpty:
		if !isRevealed: return
		elif isGrounded:
			if move == Vector2(): play_anim("idle")
			else: play_anim("walk")
		elif velocity.y < 0: play_anim("jump")
		elif velocity.y > 0: play_anim("fall")
	else:
		if !isRevealed: return
		elif isGrounded:
			if move == Vector2(): play_anim("idle")
			else: play_anim("walk")
		elif velocity.y < 0: play_anim("jump")
		elif velocity.y > 0: play_anim("fall")


func play_snd(snd) -> void:
	if !SOUNDS.has(snd): return
	sfx.stream = SOUNDS[snd]
	sfx.play()
	
func play_anim(anim) -> void:
	if anim == animPlayer.current_animation: return
	animPlayer.play(anim)

func emit() -> void:
	var newFire = fire.instance()
	get_parent().add_child(newFire)
	newFire.position = position + Vector2(0, 5)
	newFire.emitting = !newFire.emitting


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name != "reveal": return
	isRevealed = true
