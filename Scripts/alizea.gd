extends RigidBody2D

signal damage_taken(damage, direction)

enum speeds {
	EMPTY = 0
	WALK = 2
	RUN = 3
	MAX = 6
}
var speed : int = speeds.WALK
 
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

const SOUNDS = {
	"walk": preload("res://audio/sfx/walksound.wav"), 
	"jump0": preload("res://audio/sfx/jump0.wav"),
	"jump1": preload("res://audio/sfx/jump1.wav"),
	"jump2": preload("res://audio/sfx/jump2.wav")
}

const JUMP_BUFFER : float = 0.4

var velocity : Vector2
var bounceForce : Vector2
var timePressedJump : float = 0.0
var timeLeftGround : float = 0.0
var sparks : int = 0
var energy : int = 0
var health : int = 0
var isInvinsible := false
var canJump := true
var canDoubleJump := false
var wasGrounded := false
var isFlipped := true
var isRevealed := false
var isFull := false
var isEmpty := true
var isGrounded := false
var isDamaged := false
var direction : Vector2

#export(PackedScene) onready var spark
export(NodePath) onready var animPlayer = get_node(animPlayer)
export(NodePath) onready var ray = get_node(ray)
#export(PackedScene) onready var fire
export(NodePath) onready var sfx = get_node(sfx)
export(NodePath) onready var sprite32 = get_node(sprite32) as Sprite
export(NodePath) onready var sprite8 = get_node(sprite8) as Sprite

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"reveal": isRevealed = true
		"damage_taken": 
			isDamaged = false
			isInvinsible = false


func _ready() -> void:
	add_to_group("buddy")
	if !name.begins_with("sora"): play_anim("reveal")
	connect("damage_taken", self, "_on_damage_taken")


func _on_damage_taken(damage: int, dir: Vector2) -> void:
	if isInvinsible or isDamaged: return
	#if Global.orbs <= 0:
	#	print("dead")
	#	return
	Global.orbs -= damage
	print("bott took ", damage, " damage from ", dir)
	print("health is now ", health)
	isDamaged = true
	bounceForce.x = -dir.x * 275
	bounceForce.y = -275


func _physics_process(delta) -> void:
	var collider = ray.get_collider()
	var dir = ray.get_collision_normal()
	if collider:
		if collider.is_in_group("hazards"): emit_signal("damage_taken", 1, dir)
	if get_colliding_bodies() and collider: 
		isGrounded = true
		if collider.is_in_group("enemies"): collider.take_damage()
		if collider.is_in_group("boxes"): collider.destroy()
	elif !ray.get_collider(): isGrounded = false
	if isGrounded and !wasGrounded: canDoubleJump = true
#	if Input.is_action_just_pressed("ali_down"): make_spark()
	check_direction()
	set_velocity(delta)
	check_flip()
	anim_check()
	check_sprite()
	wasGrounded = isGrounded


func check_sprite():
	match Global.graphicStyle:
		"8": 
			sprite8.set_visible(true)
			sprite32.set_visible(false)
		"32": 
			sprite32.set_visible(true)
			sprite8.set_visible(false)
			
func check_flip():
	if direction.x > 0.0 and !isFlipped:  flip()
	elif direction.x < 0.0 and isFlipped: flip()


func set_velocity(delta):
	velocity += direction.normalized() * speed
	if Global.moveType == Global.moveTypes.SIDE or Global.moveType == Global.moveTypes.MARIO: 
		velocity = Vector2(check_x(delta), check_y())
	elif Global.moveType == Global.moveTypes.TOP: 
		pass
	var targetVelocity = get_target_velocity()
	velocity = velocity.linear_interpolate(targetVelocity, 0.1)
	velocity = velocity + bounceForce
	apply_central_impulse(velocity)
	bounceForce = Vector2.ZERO
	
	
func get_target_velocity() -> Vector2:
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
	var pressedJump = Input.is_action_just_pressed("ali_jump")
	var releasedJump = Input.is_action_just_released("ali_jump")
	if pressedJump:
		print("jump")
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
	elif releasedJump: velocity.y *= -0.5
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


#func make_spark() -> void:
	#if energy == 0: return
	#var newSpark : Node2D = spark.instance()
	#get_parent().add_child(newSpark)
	#newSpark.position = position
	#newSpark.get_child(0).set_emitting(true)
	#sparks += 1
	#if sparks == 2: 
	#	energy -= 1
	#	sparks = 0
#	if energy < 0: energy = 0


func get_cur_time() -> float:
	var time = OS.get_ticks_msec() / 1000.0
	return time


func check_direction():
	if Input.is_action_pressed("ali_left"): direction.x = -1
	if Input.is_action_pressed("ali_right"): direction.x = 1
	if Global.moveType == Global.moveTypes.TOP:
		if Input.is_action_pressed("ali_down"): direction.y = 1
		if Input.is_action_pressed("ali_up"): direction.y = -1
	else:
		direction.y = 0
	if Input.is_action_just_released("ali_left") or Input.is_action_just_released("ali_right"): direction.x = 0
	direction = direction.normalized()

func flip() -> void:
	sprite8.flip_h = !sprite8.flip_h
	sprite32.flip_h = !sprite32.flip_h
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


func anim_check() -> void:
	if !isRevealed or isInvinsible: return
	if name.begins_with("sora"): 
		print("sora")
		if direction.x > 0:
			if direction.y > 0: play_anim("walk_DownRight")
			elif direction.y < 0: play_anim("walk_UpRight")
			elif direction.y == 0: play_anim("walk_DownRight")
		elif direction.x < 0:
			if direction.y > 0: play_anim("walk_DownLeft")
			elif direction.y < 0: play_anim("walk_UpLeft")
			elif direction.y == 0: play_anim("walk_DownLeft")
		elif direction.x == 0:
			if direction.y > 0: play_anim("walk_DownLeft")
			elif direction.y < 0: play_anim("walk_UpRight")
			elif direction.y == 0: play_anim("idle")
			return
	if isDamaged:
		isInvinsible = true
		play_anim("damage_taken")
		print("invinsibility started")
		return
	elif isGrounded and !isDamaged:
		if direction == Vector2(): play_anim("idle")
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


#func emit() -> void:
#	var newFire = fire.instance()
#	get_parent().add_child(newFire)
#	newFire.position = position + Vector2(0, 5)
#	newFire.emitting = !newFire.emitting



