extends KinematicBody2D

signal camera_shake
signal damage_taken(damage, direction)
signal world_changed

const SOUNDS = {
	"jump": preload("res://audio/sfx/jumpEffort.wav"),
	"walk": preload("res://audio/sfx/walksquoosh.wav"),
	"grunt": preload("res://audio/voice/grunt.mp3"),
	"grunt2": preload("res://audio/voice/grunt2.mp3"),
	"grunt3": preload("res://audio/voice/hitGrunt.wav"),
	"damageTaken": preload("res://audio/voice/damageTaken.wav")
}

enum drags {
	TURN = 5
	AIR = 15
	BASIC = 18
	STOP = 40
}

enum jump_powers {
	SIDE = -210
	MARIO = -290
	TOP = -36
}

enum speeds {
	SLOW = 1
	CLIMB = 2
	WALK = 3
	RUN = 4 
	MAX = 180
}

const JUMP_BUFFER : float = 0.08
const GRAV : int = -10

#the cast_to distance of the ray
const reachVector := Vector2(100, 0)
const hitVector := Vector2(26, 0)
const closeVector := Vector2(12, 0)



var speed : int = speeds.WALK
var jumpPower : int = jump_powers.TOP

var velocity : Vector2
var direction : Vector2
var lastDirection : Vector2
var bounceForce : Vector2

var powerLevel : int = 0
var health : int = 10
var lives : int = 3
var hits : int = 0
var sparks : int = 0

var pushForce : int = 11
var grabForce : int = 7

var timePressedHit : float = 0.0
var timePressedJump : float = 0.0
var timeLeftGround : float = 0.0
var fallTime : float = 0.0

var isInvinsible := false
var wasGrounded := false
var isFacingRight := true
var isDamaged := false
var isDying := false
var isFalling := false
var isAirborne := false
var isGrounded := false
var isRunning := false
var alreadyFlipped := false
var lastCollider

export(NodePath) onready var spriteGroup = get_node(spriteGroup) as Node2D
export(NodePath) onready var topSprite = get_node(topSprite) as Sprite
export(NodePath) onready var sfx = get_node(sfx) as AudioStreamPlayer
export(NodePath) onready var sfx2 = get_node(sfx2) as AudioStreamPlayer
export(NodePath) onready var animPlayer = get_node(animPlayer) as AnimationPlayer
export(NodePath) onready var ray = get_node(ray) as RayCast2D
export(NodePath) onready var pos2D = get_node(pos2D) as Position2D
export(PackedScene) onready var hitSpark
export(PackedScene) onready var notification
onready var collisionShape = $CollisionShape2D

#func _on_groundArea_area_entered(_area) -> void: isGrounded = true
#func _on_groundArea_area_exited(_area) -> void: isGrounded = false
#func _on_groundArea_body_entered(_body) -> void: isGrounded = true
#func _on_groundArea_body_exited(_body) -> void: isGrounded = false

func _on_VisibilityNotifier2D_viewport_entered(_viewport): set_visible(true)
func _on_VisibilityNotifier2D_viewport_exited(_viewport): set_visible(false)
func _on_AnimationPlayer_animation_finished(animName) -> void:
	if animName != "side_damage": return
	match animName:
		"side_damage":
			isInvinsible = false
			print("invinsibility over")
		

func _on_damage_taken(damage: int, dir: Vector2) -> void:
	if isInvinsible: return
	isInvinsible = true
	if Global.orbs <= 0: 
		isDying = true
		play_anim("side_death", "damageTaken")
		print("dead")
		emit_signal("camera_shake", 12)
		return
	Global.orbs -= damage
	emit_signal("camera_shake", damage)
	if Global.moveType != Global.moveTypes.TOP: 
		print("lady took ", damage, " damage from ", dir)
		print("health is now ", health)
		print("invinsibility started")
		play_anim("side_damage", "damageTaken")
	bounceForce.x = -dir.x * 200
	bounceForce.y = -100
	


func _ready() -> void:
	var _damage_signal = connect("damage_taken", self, "_on_damage_taken")
	set_visible(false)


func _process(_delta) -> void:
	health = Global.orbs
	check_sprite()
	check_objects()
	check_powerLevel()


func _physics_process(delta) -> void:
	if isDying: return
	if Global.moveType == Global.moveTypes.SIDE or Global.moveType == Global.moveTypes.MARIO: isGrounded = is_on_floor()
	else: isGrounded = true
	direction = check_direction()
	set_velocity(delta)
	if Global.moveType == Global.moveTypes.SIDE or Global.moveType == Global.moveTypes.MARIO: 
		if !isAirborne: isAirborne = wasGrounded and !isGrounded
		elif velocity.y > 0 and !isFalling:
			isFalling = true
			fallTime = get_cur_time()
	if isFalling and Abilities.ability == Abilities.abilities.STOMP and Input.is_action_just_pressed("use_ability"): Abilities.isStomping = true
	if Abilities.isStomping == true: if Input.is_action_just_released("use_ability"): Abilities.isStomping = false
	check_collisions()
	if Global.moveType == Global.moveTypes.SIDE or Global.moveType == Global.moveTypes.MARIO: check_side_anim()
	else: check_top_anim()
	check_actions()
	wasGrounded = isGrounded


func set_velocity(delta) -> void:
	var drag : float
	if isGrounded: 
		if abs(Input.get_axis("sav_left", "sav_right")) <= 0.0: drag = float(drags.STOP) 
		elif sign(Input.get_axis("sav_left", "sav_right")) != sign(velocity.x): 
			play_anim("side_turn", "")
			drag = float(drags.TURN)
		else: drag = float(drags.BASIC)
	else: drag = float(drags.AIR)
	drag *= 0.01
	velocity += direction.normalized() * speed
	if Global.moveType == Global.moveTypes.SIDE or Global.moveType == Global.moveTypes.MARIO: velocity = Vector2(check_x(drag, delta), check_y())
	elif Global.moveType == Global.moveTypes.TOP: velocity = topdown_movement(drag, delta)
	if abs(velocity.x) > speeds.MAX: 
		var dir = sign(velocity.x)
		velocity.x = speeds.MAX * dir
	var targetVelocity = get_target_velocity()
	velocity = velocity.linear_interpolate(targetVelocity, 0.1)
	velocity = move_and_slide(velocity + bounceForce, Vector2.UP, false, 4, PI/4, false)
	clear_bounceForce()


func clear_bounceForce() -> void:
	bounceForce = Vector2.ZERO


func check_sprite() -> void:
	pass
	
	
func check_objects() -> void:
	var object = ray.get_collider()
	if !object: return
	#print(object.name)


#for the UI fill gauge
func check_powerLevel() -> void:
	powerLevel = Global.orbs / 10 + 1


func check_side_anim() -> void:
	if topSprite.visible == true: topSprite.set_visible(false)
	if wasGrounded:
		if !Abilities.isHitting and !Abilities.isGrabbing:
			if direction == Vector2(): 
				if Input.is_action_pressed("sav_up"): play_anim("side_look_up", "")
				else: play_anim("side_idle", "")
			else: 
				if speed == speeds.WALK: 
					play_anim("side_walk", "")
					isRunning = false
				elif speed == speeds.RUN: 
					isRunning = true
					play_anim("side_run", "")
	elif velocity.y < 0: play_anim("side_jump", "jump")
	elif velocity.y > 0: play_anim("side_fall", "")


func check_top_anim() -> void: 
	if topSprite.visible == false: topSprite.set_visible(true)


func check_actions() -> void:
	if Input.is_action_pressed("run") and isGrounded: speed = speeds.RUN
	elif Input.is_action_just_released("run"): speed = speeds.WALK
	if Input.is_action_just_pressed("hit"): hit()
	elif Input.is_action_pressed("use_ability"): use_ability()
	elif Input.is_action_pressed("interact"): grab()
	elif Input.is_action_just_pressed("change_ability"): Abilities.change_ability()
	
	if Input.is_action_pressed("sav_down"):  if Global.moveType == Global.moveTypes.SIDE or Global.moveType == Global.moveTypes.MARIO: play_anim("side_duck", "")
	
	#if Input.is_action_just_released("use_ability"): deactivate_ability()
	if Input.is_action_just_released("hit"): Abilities.isHitting = false
	elif Input.is_action_just_released("interact"): ungrab()

func use_ability() -> void:
	match Abilities.ability:
		Abilities.abilities.NONE: 
			print("no ability")
			return
		Abilities.abilities.REACH: pass
		Abilities.abilities.HANG: pass
		Abilities.abilities.STOMP: pass
	print("ability activated")


func deactivate_ability() -> void:
	match Abilities.ability:
		Abilities.abilities.NONE: pass
		Abilities.abilities.REACH: pass
		Abilities.abilities.HANG: unhang()
		Abilities.abilities.STOMP: pass
	print("ability deactivated")


func ungrab() -> void:
	Abilities.isGrabbing = false
	speed = speeds.WALK


func unhang() -> void: Abilities.isHanging = false


func jump() -> void:
	play_snd("jump")
	var coinFlip = randi() % 2
	if coinFlip == 0: play_snd("grunt")
	else: play_snd("grunt2")
	match Global.moveType:
		Global.moveTypes.SIDE: jumpPower = jump_powers.SIDE
		Global.moveTypes.MARIO: jumpPower = jump_powers.MARIO
		Global.moveTypes.TOP: jumpPower = jump_powers.TOP
	velocity.y = jumpPower


#flip everything when the character turns left or right
func check_flip() -> void:
	if Global.moveType == Global.moveTypes.TOP: return
	if direction.x > 0.0 and !isFacingRight:
		if alreadyFlipped: return
		if !Abilities.isGrabbing: flip()
	elif direction.x < 0.0 and isFacingRight:
		if !Abilities.isGrabbing: flip()
	if !isFacingRight:
		pos2D.position.x = -9
		if Abilities.canReach: 
			if Abilities.isGrabbing: ray.set_cast_to(-reachVector)
			else: ray.set_cast_to(-hitVector)
		else: ray.set_cast_to(-closeVector)
		return
	pos2D.position.x = 3
	if Abilities.canReach: 
		if Abilities.isGrabbing: ray.set_cast_to(reachVector)
		else: ray.set_cast_to(hitVector)
	else: ray.set_cast_to(closeVector)


func flip() -> void:
	var sprites = spriteGroup.get_children()
	if Abilities.isGrabbing: return
	for sprite in sprites:
		sprite.flip_h = !sprite.flip_h
	isFacingRight = !isFacingRight


func play_anim(anim, snd) -> void:
	if animPlayer.current_animation == anim: return
	match animPlayer.current_animation:
		"side_death": return
		"side_damage": return
	animPlayer.play(anim)
	play_snd(snd)


func walk_sound() -> void: play_snd("walk")


func play_snd(snd) -> void:
	if SOUNDS.has(snd):
		if !sfx.is_playing():
			sfx.stream = SOUNDS[snd]
			sfx.play()
		else:
			sfx2.stream = SOUNDS[snd]
			sfx2.play()


func check_collisions() -> void:
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		var collider = collision.collider
		if !isGrounded and Abilities.canHang:
			if collision.normal.x == -1: 
				if Input.is_action_pressed("use_ability") and Abilities.ability == Abilities.abilities.HANG: Abilities.isHanging = true
				elif Input.is_action_just_released("use_ability"): Abilities.isHanging = false
			elif collision.normal.x == 1:
				if Input.is_action_pressed("use_ability") and Abilities.ability == Abilities.abilities.HANG: Abilities.isHanging = true
				elif Input.is_action_just_released("use_ability"): Abilities.isHanging = false
		if collision.normal.y == 1:
			print("you hit your head")
			if collider.is_in_group("breakable"):
				Global.orbs += 1
				collider.destroy()
			
		elif collision.normal.y == -1: 
			if isAirborne: isAirborne = false
			if isFalling:
				if collider.is_in_group("enemies"): 
					print(collider.name, " attacked")
					bounceForce.y = -120
					collider.take_damage()
				play_snd("walk")
				isFalling = false
				if Input.is_action_pressed("use_ability") and Abilities.canStomp: if collider.is_in_group("breakable"): collider.queue_free()
		
		
		if collider.is_in_group("boxes") or collider.is_in_group("buddy"):
			Abilities.isGrabbing = false
			collider.apply_central_impulse(-collision.normal * pushForce)


func spark(isMoving) -> void:
	if Global.orbs == 0:
		print("no power")
		return
	var newSpark : Node2D = hitSpark.instance()
	get_parent().add_child(newSpark)
	newSpark.position = position
	if isMoving: 
		print("moving spark")
		newSpark.direction = sign(velocity.x)
		newSpark.isMoving = true
	sparks += 1
	if sparks == 3:
		Global.orbs -= 1
		sparks = 0
	if Global.orbs < 0: Global.orbs = 0
	if !isFacingRight:
		newSpark.position.x = position.x - 12
		newSpark.get_node("Sprite").flip_h = true
	else: newSpark.position.x += 12


func hit() -> void:
	Abilities.isHitting = true
	match Global.moveType:
		Global.moveTypes.SIDE:
			if animPlayer.current_animation != "side_hit": 
				play_snd("grunt3")
				play_anim("side_hit", "grunt3")
		Global.moveTypes.MARIO:
			if animPlayer.current_animation != "side_hit": 
				play_snd("grunt3")
				play_anim("side_hit", "grunt3")
		Global.moveTypes.TOP: pass
	var collider = ray.get_collider()
	if Global.orbs > 0 and Abilities.canReach: spark(false)
	if !collider:
		hits = 0
		return
	print(collider.name)
	if !lastCollider: lastCollider = collider
	elif collider != lastCollider: 
		lastCollider = collider
		hits = 0
	if collider.is_in_group("hitable"):
		if Global.orbs > 0: collider.hit(2, isFacingRight)
		else: collider.hit(1, isFacingRight)
	hits += 1
	emit_signal("camera_shake", pow(1.5, hits))
	timePressedHit = get_cur_time()
	if get_cur_time() - timePressedHit > 1.22: hits = 0
	if hits > 3: hits = 3


func grab() -> void:
	print("grabbing")
	speed = speeds.CLIMB
	if !Abilities.isGrabbing:
		if Abilities.canReach: spark(true)
		Abilities.isGrabbing = true
		match Global.moveType:
			Global.moveTypes.SIDE: play_anim("side_grab", "")
			Global.moveTypes.MARIO: play_anim("side_grab", "")
			Global.moveTypes.TOP: pass
	var collider = ray.get_collider()
	if !collider: return
	if collider.is_in_group("hitable"):
		if collider is RigidBody2D: 
			var hitForce = velocity.x
			if abs(hitForce) >= 10: hitForce = sign(velocity.x) * 10
			elif abs(hitForce) < 4 : hitForce = sign(velocity.x) * 4
			print(hitForce)
			collider.apply_central_impulse(Vector2(hitForce, 0))


func check_direction() -> Vector2:
	direction = Vector2()
	if Input.is_action_pressed("sav_left"): 
		direction.x -= 1
		check_flip()
	if Input.is_action_pressed("sav_right"): 
		direction.x += 1
		check_flip()
	if Input.is_action_pressed("sav_up") and Global.get_moveType() == Global.moveTypes.TOP: 
		direction.y -= 1
		check_flip()
	if Input.is_action_pressed("sav_down") and Global.get_moveType() == Global.moveTypes.TOP: 
		direction.y += 1
		check_flip()

	return direction


func get_target_velocity() -> Vector2:
	if direction.x == 0:
		if velocity.x > -10 and velocity.x < 10: velocity.x = 0
	return velocity


func topdown_movement(drag, delta) -> Vector2:
	velocity *= pow(1 - drag, delta * 10)
	return velocity


func check_x(drag, delta) -> float:
	velocity.x *= pow(1 - drag, delta * 10)
	return velocity.x


func check_y() -> float:
	if velocity.y < -375: velocity.y = -375
	if Abilities.isHanging:
		if Input.is_action_pressed("sav_up"): velocity.y = -speeds.CLIMB
		else: velocity.y = 0
		if Input.is_action_just_pressed("sav_left"): unhang()
		elif Input.is_action_just_pressed("sav_right"): unhang()
		elif Input.is_action_just_released("sav_up"): unhang()
		return velocity.y
	if !isGrounded and wasGrounded: timeLeftGround = get_cur_time()
	var pressedJump = Input.is_action_just_pressed("jump")
	var releasedJump = Input.is_action_just_released("jump")
	if releasedJump and sign(velocity.y) == -1: velocity.y *= 0.4
	elif pressedJump:
		timePressedJump = get_cur_time()
		if isGrounded: jump()
		elif get_cur_time() - timeLeftGround < JUMP_BUFFER:
			jump()
		if isGrounded and !isDamaged: velocity.y = jumpPower
	else: velocity.y -= GRAV
	var timeDifference = get_cur_time() - timePressedJump
	if isGrounded and velocity.y > 0: velocity.y = 0
	elif !wasGrounded and isGrounded and timeDifference < JUMP_BUFFER:
		jump()
	return velocity.y


func get_cur_time() -> float: return OS.get_ticks_msec() / 1000.0

  

