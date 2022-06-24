extends KinematicBody2D
#maybe convert this to a rhythm game when able
signal something_hit

const SOUNDS = {
	"jump": preload("res://audio/jumpEffort.wav"),
	"walk": preload("res://audio/walksquoosh.wav")
}

const JUMP_BUFFER : float = 0.08
const DRAG_GROUND : float = 0.7
const DRAG_AIR : float = 0.65
const GRAV : int = -10
const JUMP_POWER : int = -250
const reachVector := Vector2(100, 0)
const hitVector := Vector2(16, 0)
const closeVector := Vector2(10, 0)


enum speeds {
	SLOW = 4
	WALK = 13
	RUN = 19 
}

var velocity : Vector2
var direction : Vector2
var lastDirection : Vector2

var powerLevel : int = 0
var lives : int = 3
var hits : int = 0
var sparks : int = 0
var speed : int = speeds.WALK
var pushForce : int = 11
var grabForce : int = 7

var timePressedHit : float = 0.0
var timePressedJump : float = 0.0
var timeLeftGround : float = 0.0
var fallTime : float = 0.0

var wasGrounded := false
var isFlipped := true
var isDead := false
var isDying := false
var isGrabbing := false
var canReach = false
var canHang = false
var isHitting := false
var isFalling := false
var isHanging := false
var isAirborne := false
var isGrounded := false
var lastCollider

export(NodePath) onready var sprite = get_node(sprite) as Sprite
export(NodePath) onready var sfx = get_node(sfx) as AudioStreamPlayer
export(NodePath) onready var animPlayer = get_node(animPlayer) as AnimationPlayer
export(NodePath) onready var particle = get_node(particle) as CPUParticles2D
export(NodePath) onready var ray = get_node(ray) as RayCast2D
export(NodePath) onready var pos2D = get_node(pos2D) as Position2D
export(PackedScene) onready var hitSpark
export(PackedScene) onready var notification


func _on_groundArea_area_entered(_area): isGrounded = true
func _on_groundArea_area_exited(_area): isGrounded = false
func _on_groundArea_body_entered(_body): isGrounded = true
func _on_groundArea_body_exited(_body): isGrounded = false


func _on_AnimationPlayer_animation_finished(animName) -> void:
	if animName != "damage": return
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()


func _ready() -> void:
	play_anim("idle")

	
func _process(_delta) -> void:
	check_objects()
	check_powerLevel()

func set_velocity(delta):
	var drag : float
	if isGrounded: drag = DRAG_GROUND
	else: drag = DRAG_AIR
	velocity += direction.normalized() * speed
	velocity = Vector2(check_x(drag, delta), check_y())
	if velocity.x > -2 and velocity.x < 2: velocity.x = 0
	var targetVelocity = get_target_velocity()
	velocity = velocity.linear_interpolate(targetVelocity, 0.1)
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false)

func _physics_process(delta) -> void:
	if isDying: return
	elif isDead:
		Global.orbs = 0
		isDying = true
		play_anim("damage")
		emit_signal("something_hit", 12)
		return
	
	isGrounded = is_on_floor()
	direction = Vector2(check_direction(), 0)
	set_velocity(delta)
	
	
	
	if !isAirborne: isAirborne = wasGrounded and !isGrounded
	elif velocity.y > 0 and !isFalling:
		isFalling = true
		fallTime = get_cur_time()
		
	check_collisions()
	check_anim()
	check_actions()
	wasGrounded = isGrounded


func check_objects():
	var object = ray.get_collider()
	if !object: return
	if object is Selectable: object.isSelectable = true

#for the UI fill gauge
func check_powerLevel():
	if Global.orbs >= 100: powerLevel = 0 
	elif Global.orbs >= 80: powerLevel = 1
	elif Global.orbs >= 50: powerLevel = 2
	elif Global.orbs >= 20: powerLevel = 3
	elif Global.orbs >= 10: powerLevel = 4
	elif Global.orbs >= 5: powerLevel = 5
	elif Global.orbs >= 1: powerLevel = 6
	elif Global.orbs == 0: powerLevel = 7


func check_anim():
	check_flip()
	if wasGrounded:
		if !isHitting and !isGrabbing:
			if direction == Vector2(): play_anim("idle")
			else: play_anim("walk")
	elif velocity.y < 0: play_anim("jump")
	elif velocity.y > 0: play_anim("fall")


func get_target_velocity():
	if direction.x == 0:
		if velocity.x > -10 and velocity.x < 10: velocity.x = 0
	return velocity


func check_actions():
	if Input.is_action_pressed("run") and isGrounded: speed = speeds.RUN
	elif Input.is_action_just_released("run"): speed = speeds.WALK
	
	if Input.is_action_just_pressed("hit"):
		isHitting = true
		hit()
		
	elif Input.is_action_pressed("grab"):
		grab()
		speed = speeds.SLOW
	
	if Input.is_action_just_released("grab"):
		isGrabbing = false
		speed = speeds.WALK
	elif Input.is_action_just_released("hit"): isHitting = false


func check_direction():
	var move_x : int = 0
	if Input.is_action_pressed("sav_left"):
		move_x -= 1
		particle.emitting = true
	elif Input.is_action_pressed("sav_right"):
		move_x += 1
		particle.emitting = true
	return move_x


func check_x(drag, delta) -> float:
	velocity.x *= pow(1 - drag, delta * 10)
	return velocity.x


func check_y() -> float:
	if isHanging:
		print("hanging")
		if Input.is_action_pressed("sav_up"): velocity.y = -speeds.SLOW
		else: velocity.y = 0
		return velocity.y
	if !isGrounded and wasGrounded: timeLeftGround = get_cur_time()
	var pressedJump = Input.is_action_just_pressed("sav_up")
	var releasedJump = Input.is_action_just_released("sav_up")
	if releasedJump and sign(velocity.y) == -1: velocity.y *= 0.4
	elif pressedJump:
		timePressedJump = get_cur_time()
		if isGrounded:
			play_snd("jump")
			velocity.y = JUMP_POWER
		elif get_cur_time() - timeLeftGround < JUMP_BUFFER:
			play_snd("jump")
			velocity.y = JUMP_POWER
		particle.emitting = true
		if isGrounded and !isDead: velocity.y = JUMP_POWER
	else: velocity.y -= GRAV
	var timeDifference = get_cur_time() - timePressedJump
	if isGrounded and velocity.y > 0: velocity.y = 0
	elif !wasGrounded and isGrounded and timeDifference < JUMP_BUFFER:
		play_snd("jump")
		velocity.y = JUMP_POWER
	return velocity.y


func check_flip():
	if direction.x > 0.0 and !isFlipped:
		if !isGrabbing: flip()
	elif direction.x < 0.0 and isFlipped:
		if !isGrabbing: flip()
		
	if !isFlipped:
		pos2D.position.x = -3
		if Global.orbs > 0 and canReach: 
			if isGrabbing: ray.set_cast_to(-reachVector)
			else: ray.set_cast_to(-hitVector)
		else: ray.set_cast_to(-closeVector)
		return
	pos2D.position.x = 3
	if Global.orbs > 0 and canReach: 
		if isGrabbing: ray.set_cast_to(reachVector)
		else: ray.set_cast_to(hitVector)
	else: ray.set_cast_to(closeVector)
	

func get_cur_time() -> float:
	return OS.get_ticks_msec() / 1000.0


func flip() -> void:
	if !isGrabbing:
		sprite.flip_h = !sprite.flip_h
		isFlipped = !isFlipped
	
	

func play_anim(anim) -> void:
	if animPlayer.current_animation == anim: return
	animPlayer.play(anim)


func walk_sound() -> void:
	play_snd("walk")


func play_snd(snd) -> void:
	if SOUNDS.has(snd):
		sfx.stream = SOUNDS[snd]
		sfx.play()


func check_collisions():
	for index in get_slide_count():
		var body = get_slide_collision(index)
		var collider = body.collider
		if !isGrounded and canHang:
			if body.normal.x == -1: 
				if Input.is_action_pressed("hit"): isHanging = true
				else: isHanging = false
			elif body.normal.x == 1:
				if Input.is_action_pressed("hit"): isHanging = true
				else: isHanging = false
		
		if body.normal.y == 1:
			if collider.is_in_group("boxes"): 
				collider.apply_central_impulse(Vector2(randi()%10, 0))
				print("there's a box on your head")
		elif body.normal.y == -1: 
			if isAirborne: isAirborne = false
			if isFalling:
				play_snd("walk")
				isFalling = false
				if Input.is_action_pressed("sav_down") and canReach and Global.orbs > 0:
					if collider.is_in_group("breakable"): collider.queue_free()
				var timeCheck = get_cur_time() - fallTime
				if timeCheck > 0.8:
					if timeCheck > 0.85 and collider.is_in_group("boxes"):
						if collider.name.find("orb") == -1:
							if !collider.is_in_group("buddy"): collider.queue_free()
						else:
							if !collider.isBroken:
								collider.set_broken(true)
								collider.get_node("boxCollision").queue_free()
					if timeCheck > 10: timeCheck = 10
					emit_signal("something_hit", pow(2, timeCheck))
		
		if collider.is_in_group("boxes") and !collider.is_in_group("buddy"):
			isGrabbing = false
			collider.apply_central_impulse(-body.normal * pushForce)

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
	if !isFlipped:
		newSpark.position.x = position.x - 12
		newSpark.get_node("Sprite").flip_h = true
	else: newSpark.position.x += 12


func hit() -> void:
	play_anim("hit")
	var collider = ray.get_collider()
	if Global.orbs > 0 and canReach: spark(false)
	if !collider:
		hits = 0
		return
	print(collider.name)
	if collider.name == "fakeWall": collider.queue_free()
	if !lastCollider: lastCollider = collider
	elif collider != lastCollider: 
		lastCollider = collider
		hits = 0
	elif collider.is_in_group("hitable"):
		if Global.orbs > 0: collider.hit += 2
		else: collider.hit += 1
		if isFlipped: 
			collider.apply_central_impulse(Vector2(80, 0))
		else: 
			collider.apply_central_impulse(Vector2(-80, 0))
	hits += 1
	emit_signal("something_hit", pow(1.5, hits))
	timePressedHit = get_cur_time()
	if get_cur_time() - timePressedHit > 1.22: hits = 0
	if hits > 3: hits = 3


func grab() -> void:
	if !isGrabbing:
		if canReach: spark(true)
		isGrabbing = true
		play_anim("grab")
	var collider = ray.get_collider()
	if !collider: return
	if collider.is_in_group("hitable"):
		if collider.is_in_group("drones"): 
			collider.get_node("Timer").start()
			collider.isGrabbed = true
		collider.apply_central_impulse(Vector2(velocity.x, 0))
