extends KinematicBody2D

#signal camera_shake
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
var pickup


var powerLevel : int = 0
var health : int = 10
var lives : int = 3
var hits : int = 0
var sparks : int = 0

var pushForce : int = 11
var grabForce : int = 2

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

export(NodePath) onready var spriteGroup32 = get_node(spriteGroup32) as Node2D
export(NodePath) onready var spriteGroup8 = get_node(spriteGroup8) as Node2D
export(NodePath) onready var topSprite32 = get_node(topSprite32) as Sprite
export(NodePath) onready var topSprite8 = get_node(topSprite8) as Sprite
export(NodePath) onready var sfx = get_node(sfx) as AudioStreamPlayer
export(NodePath) onready var sfx2 = get_node(sfx2) as AudioStreamPlayer
export(NodePath) onready var animPlayer = get_node(animPlayer) as AnimationPlayer
export(NodePath) onready var ray = get_node(ray) as RayCast2D
export(NodePath) onready var pickupSpot = get_node(pickupSpot) as Position2D
export(PackedScene) onready var hitSpark
export(PackedScene) onready var notif
onready var collisionShape = $CollisionShape2D

#func _on_groundArea_area_entered(_area) -> void: isGrounded = true
#func _on_groundArea_area_exited(_area) -> void: isGrounded = false
#func _on_groundArea_body_entered(_body) -> void: isGrounded = true
#func _on_groundArea_body_exited(_body) -> void: isGrounded = false

func _on_VisibilityNotifier2D_viewport_entered(_viewport): set_visible(true)
func _on_VisibilityNotifier2D_viewport_exited(_viewport): set_visible(false)
func _on_AnimationPlayer_animation_finished(animName) -> void:
	if animName != "damage": return
	match animName:
		"damage":
			isInvinsible = false
			print("invinsibility over")
		

func _on_damage_taken(damage: int, dir: Vector2) -> void:
	if isInvinsible: return
	isInvinsible = true
	if Global.orbs <= 0: 
		isDying = true
		play_anim("death", "damageTaken")
		print("dead")
		Global.camera.shake(100)
		return
	Global.orbs -= damage
	Global.camera.shake(damage * 10)
	if Global.moveType != Global.moveTypes.TOP: 
		print("lady took ", damage, " damage from ", dir)
		print("health is now ", health)
		print("invinsibility started")
		play_anim("damage", "damageTaken")
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
	if Global.moveType == Global.moveTypes.SIDE or Global.moveType == Global.moveTypes.MARIO: check_anim()
	else: check_top_anim()
	wasGrounded = isGrounded


func set_velocity(delta) -> void:
	var drag : float
	if isGrounded and Global.moveType != Global.moveTypes.TOP: 
		if abs(Input.get_axis("sav_left", "sav_right")) <= 0.0: drag = float(drags.STOP) 
		elif sign(Input.get_axis("sav_left", "sav_right")) != sign(velocity.x): 
			play_anim("turn", "")
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
	bounceForce = Vector2.ZERO



func check_sprite() -> void:
	match Global.graphicStyle:
		"8": 
			spriteGroup8.set_visible(true)
			spriteGroup32.set_visible(false)
		"32": 
			spriteGroup32.set_visible(true)
			spriteGroup8.set_visible(false)
	
	
func check_objects() -> void:
	var object = ray.get_collider()
	if !object: return
	#print(object.name)


#for the UI fill gauge
func check_powerLevel() -> void:
	powerLevel = Global.orbs / 10 + 1


func check_anim() -> void:
	if topSprite32.visible == true: topSprite32.set_visible(false)
	if topSprite8.visible == true: topSprite8.set_visible(false)
	if wasGrounded:
		if !Abilities.isHitting and !Abilities.isGrabbing:
			if direction == Vector2(): 
				if Input.is_action_pressed("sav_up"): play_anim("look_up", "")
				else: play_anim("idle", "")
			else: 
				if speed == speeds.WALK: 
					play_anim("walk", "")
					isRunning = false
				elif speed == speeds.RUN: 
					isRunning = true
					play_anim("run", "")
	elif velocity.y < 0: play_anim("jump", "jump")
	elif velocity.y > 0: play_anim("fall", "")


func check_top_anim() -> void: 
	if topSprite32.visible == false: topSprite32.set_visible(true)
	
	
func _input(event):
	if Input.is_action_just_pressed("notif"): notif()
	if Input.is_action_just_pressed("drop"): if pickup: set_down()
	if Input.is_action_pressed("run") and isGrounded: speed = speeds.RUN
	elif Input.is_action_just_released("run"): speed = speeds.WALK
	if Input.is_action_just_pressed("hit"): hit()
	elif Input.is_action_pressed("use_ability"): use_ability()
	elif Input.is_action_pressed("interact"): grab()
	elif Input.is_action_just_pressed("change_ability"): Abilities.change_ability()
	
	if Input.is_action_pressed("sav_down"):  if Global.moveType == Global.moveTypes.SIDE or Global.moveType == Global.moveTypes.MARIO: play_anim("duck", "")
	
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
	grabForce = 0
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
	if direction.x > 0.0 and isFacingRight:
		if !Abilities.isGrabbing: 
			var sprites = spriteGroup32.get_children() + spriteGroup8.get_children()
			for sprite in sprites:
				sprite.flip_h = false
				isFacingRight = false
	elif direction.x < 0.0 and !isFacingRight:
		if !Abilities.isGrabbing: 
			var sprites = spriteGroup32.get_children() + spriteGroup8.get_children()
			for sprite in sprites:
				sprite.flip_h = true
				isFacingRight = true
	
	if isFacingRight:
		pickupSpot.position.x = -9
		if Abilities.canReach: 
			if Abilities.isGrabbing: ray.set_cast_to(-reachVector)
			else: ray.set_cast_to(-hitVector)
		else: ray.set_cast_to(-closeVector)
		return
	pickupSpot.position.x = 3
	if Abilities.canReach: 
		if Abilities.isGrabbing: ray.set_cast_to(reachVector)
		else: ray.set_cast_to(hitVector)
	else: ray.set_cast_to(closeVector)




func play_anim(anim, snd) -> void:
	if animPlayer.current_animation == anim: return
	match animPlayer.current_animation:
		"death": return
		"damage": return
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
	if ray.is_colliding():
		var collider = ray.get_collider()
		var dir = ray.get_collision_normal()
		if collider.is_in_group("hazards"): emit_signal("damage_taken", 1, -dir)
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		var collider = collision.collider
		if collision.normal.y == 1:
			print("you hit your head")
			if collider.is_in_group("breakable"):
				Global.orbs += 1
				collider.destroy()
		if collision.normal.y == -1: 
			if isAirborne: isAirborne = false
			if isFalling:
				if collider.is_in_group("enemies"): 
					print(collider.name, " attacked")
					bounceForce.y = -120
					collider.take_damage()
				play_snd("walk")
				isFalling = false
				if Input.is_action_pressed("sav_down"): if collider.is_in_group("breakable"): collider.destroy()
		if collider.is_in_group("boxes") or collider.is_in_group("buddy"):
			Abilities.isGrabbing = false
			collider.apply_central_impulse(-collision.normal * pushForce)
		if !isGrounded and Abilities.canHang:
			if collision.normal.x == -1: 
				if Input.is_action_pressed("use_ability") and Abilities.ability == Abilities.abilities.HANG: Abilities.isHanging = true
				elif Input.is_action_just_released("use_ability"): Abilities.isHanging = false
			elif collision.normal.x == 1:
				if Input.is_action_pressed("use_ability") and Abilities.ability == Abilities.abilities.HANG: Abilities.isHanging = true
				elif Input.is_action_just_released("use_ability"): Abilities.isHanging = false


func set_down():
	pickup.get_parent().remove_child(pickup)
	get_parent().add_child(pickup)
	pickup.position = position
	if pickup is RigidBody2D: 
		pickup.set_mode(RigidBody2D.MODE_RIGID)
		pickup.collision.set_disabled(false)
		pickup.pickupTimer.start()
		pickup.continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	pickup = null
	
	

func pickup_item(item):
	if pickup: return
	pickup = item
	item.get_parent().remove_child(item)
	pickupSpot.add_child(item)
	if item is RigidBody2D: 
		item.set_mode(RigidBody2D.MODE_STATIC)
		item.collision.set_disabled(true)
		item.continuous_cd = RigidBody2D.CCD_MODE_DISABLED
		item.rotation = 0
	item.position = pickupSpot.position


func notif():
	print("notification created")
	var newNotif : Node2D = notif.instance()
	add_child(newNotif)
	newNotif.position = position
	newNotif.destination.x = position.x
	newNotif.destination.y += position.y
	remove_child(newNotif)
	get_parent().add_child(newNotif)
	newNotif.set_deferred("canNotify", true)
	

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
	if isFacingRight:
		newSpark.position.x -= 12
		newSpark.get_node("Sprite").flip_h = true
	else: newSpark.position.x += 12


func hit() -> void:
	Abilities.isHitting = true
	match Global.moveType:
		Global.moveTypes.SIDE:
			if animPlayer.current_animation != "hit": 
				play_snd("grunt3")
				play_anim("hit", "grunt3")
		Global.moveTypes.MARIO:
			if animPlayer.current_animation != "hit": 
				play_snd("grunt3")
				play_anim("hit", "grunt3")
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
		if Global.orbs > 0: collider.take_damage(2, isFacingRight)
		else: collider.take_damage(1, isFacingRight)
	hits += 1
	Global.camera.shake(25)
	timePressedHit = get_cur_time()
	if get_cur_time() - timePressedHit > 1.22: hits = 0
	if hits > 3: hits = 3


func grab() -> void:
	speed = speeds.CLIMB
	if !Abilities.isGrabbing:
		Abilities.isGrabbing = true
		match Global.moveType:
			Global.moveTypes.SIDE: play_anim("grab", "")
			Global.moveTypes.MARIO: play_anim("grab", "")
			Global.moveTypes.TOP: pass
	var collider = ray.get_collider()
	if !collider: return
	print(collider.name)
	if collider.is_in_group("grabable"):
		if collider is RigidBody2D: 
			grabForce += velocity.x
			var dir = int(isFacingRight)
			if dir == 0: dir = 1
			else: dir = -1
			if abs(grabForce) < 150: grabForce = 150 * dir
			print(grabForce)
			collider.apply_central_impulse(Vector2(grabForce, 0))


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

  

