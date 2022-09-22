extends KinematicBody2D

#signal camera_shake
signal damage_taken(damage, direction)
signal world_changed
signal gravity_shifted(direction)

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
	TOP = 30
	STOP = 80
}

enum jump_powers {
	TOP = -36	
	SIDE = -210
	MARIO = -290
}

enum speeds {
	SLOW = 1
	TOP = 2
	WALK = 3
	RUN = 4 
	CLIMB = 18
	MAX = 110
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

var timePressedHit : float = 0.0
var timePressedJump : float = 0.0
var timeLeftGround : float = 0.0
var fallTime : float = 0.0

var isInvinsible := false
var wasGrounded := false
var isFacingRight := false
var isDamaged := false
var isDying := false
var isFalling := false
var isAirborne := false
var isGrounded := false
var isTouchingWall := false
var isRunning := false
var lastCollider
var items_in_hand = []

export(NodePath) onready var sideSprites = get_node(sideSprites) as Node2D
export(NodePath) onready var topSprites = get_node(topSprites) as Node2D

onready var sideSprite8 = sideSprites.get_child(0)
onready var sideSprite32 = sideSprites.get_child(1)
onready var topSprite8 = topSprites.get_child(0)
onready var topSprite32 = topSprites.get_child(1)
var spriteGroup8 : Array
var spriteGroup32 : Array
var gravityShift : Vector2

export(NodePath) onready var sfx = get_node(sfx) as AudioStreamPlayer
export(NodePath) onready var sfx2 = get_node(sfx2) as AudioStreamPlayer
export(NodePath) onready var animPlayer = get_node(animPlayer) as AnimationPlayer
export(NodePath) onready var ray = get_node(ray) as RayCast2D
export(NodePath) onready var pickupSpot = get_node(pickupSpot) as Position2D
export(PackedScene) onready var hitSpark
export(PackedScene) onready var notif

var isTurning := false


func _on_VisibilityNotifier2D_viewport_entered(_viewport): set_visible(true)


func _on_VisibilityNotifier2D_viewport_exited(_viewport): set_visible(false)


func _on_AnimationPlayer_animation_finished(animName) -> void:
	if animName != "damage": return
	match animName:
		"damage":
			isInvinsible = false
			print("invinsibility over")
		
func _on_gravity_shifted(direction):
	return
	#gravityShift = GRAV * direction
	#print(gravityShift)
	
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
	var _gravity_signal = connect("gravity_shifted", self, "_on_gravity_shifted")
	var _damage_signal = connect("damage_taken", self, "_on_damage_taken")
	set_visible(false)
	spriteGroup32.append(topSprite32)
	spriteGroup32.append(sideSprite32)
	spriteGroup8.append(sideSprite8)
	spriteGroup8.append(sideSprite8)


func _process(_delta) -> void:
	health = Global.orbs
	check_sprite()
	check_objects()
	check_powerLevel()
	check_flip()


func _physics_process(delta) -> void:
	if isDying: return
	if Global.moveType != Global.moveTypes.TOP: 
		if $sideShape.is_disabled():
			print("top shape set disabled")
			$topDownShape.set_disabled(true)
			$sideShape.set_disabled(false)
			print($topDownShape.is_disabled())
		isGrounded = is_on_floor()
	else:
		if $topDownShape.is_disabled():
			print("top shape set disabled")
			$sideShape.set_disabled(true)
			$topDownShape.set_disabled(false)
			print($topDownShape.is_disabled())
		isGrounded = true
	direction = check_direction()
	set_velocity(delta)
	if Global.moveType == Global.moveTypes.SIDE or Global.moveType == Global.moveTypes.MARIO: 
		if !isAirborne: isAirborne = wasGrounded and !isGrounded
		elif velocity.y > 0 and !isFalling:
			isFalling = true
			fallTime = get_cur_time()
	if isFalling and Abilities.current_ability == Abilities.abilities.TRANSLATE and Input.is_action_just_pressed("use_ability"): Abilities.isTranslateing = true
	if Abilities.isTranslateing == true: if Input.is_action_just_released("use_ability"): Abilities.isTranslateing = false
	check_collisions()
	check_anim()
	wasGrounded = isGrounded


func set_velocity(delta) -> void:
	var drag : float
	if isGrounded:
		var horizontal_move : float = Input.get_axis("sav_left", "sav_right")
		var vertical_move : float = Input.get_axis("sav_up", "sav_down")
		if Global.moveType != Global.moveTypes.TOP:
			if abs(horizontal_move) <= 0.0: 
				isTurning = false
				drag = drags.STOP
			elif sign(horizontal_move) != sign(velocity.x): 
				isTurning = true
				drag = float(drags.TURN)
			else:
				isTurning = false
				drag = float(drags.BASIC)
		else:
			if abs(horizontal_move) <= 0.0 and abs(vertical_move) <= 0.0:
				isTurning = false
				drag = float(drags.STOP)
			else:
				isTurning = false
				drag = float(drags.TOP)
	else: 
		isTurning = false
		drag = float(drags.AIR)
	drag *= 0.01
	velocity += direction.normalized() * speed
	if Global.moveType == Global.moveTypes.SIDE or Global.moveType == Global.moveTypes.MARIO: velocity = Vector2(check_x(drag, delta), check_y())
	elif Global.moveType == Global.moveTypes.TOP: velocity = topdown_movement(drag, delta)
	if abs(velocity.x) > speeds.MAX: 
		var dir = sign(velocity.x)
		velocity.x = speeds.MAX * dir
	var targetVelocity = get_target_velocity()
	velocity = velocity.linear_interpolate(targetVelocity, 0.1)
	velocity += bounceForce
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false)
	set_deferred("bounceForce", Vector2.ZERO)


func check_sprite() -> void:
	if Global.isGraphicsSet == true: return
	match Global.graphicStyle:
		"8": 
			Global.isGraphicsSet = true
			for i in spriteGroup8: i.set_visible(true)
			for i in spriteGroup32: i.set_visible(false)
			return
		"32": 
			Global.isGraphicsSet = true
			for i in spriteGroup32: i.set_visible(true)
			for i in spriteGroup8: i.set_visible(false)
			return


func check_objects() -> void:
	var object = ray.get_collider()
	if !object: return
	#print(object.name)


#for the UI fill gauge
func check_powerLevel() -> void:
	powerLevel = Global.orbs / 10 + 1


func check_anim() -> void:
	if Global.moveType != Global.moveTypes.TOP:
		if $topAnimation.current_animation != "": $topAnimation.current_animation = ""
		animPlayer = $sideAnimation
		if topSprites.visible == true: topSprites.set_visible(false)
		if sideSprites.visible == false: sideSprites.set_visible(true)
		if wasGrounded:
			if !Abilities.isHitting and !Abilities.isGrabbing:
				if direction == Vector2(): 
					if Input.is_action_pressed("sav_up"): play_anim("look_up", "")
					elif Input.is_action_pressed("sav_down"): play_anim("duck", "")
					else: play_anim("idle", "")
				else: 
					if isTurning: 
						play_anim("turn", "")
						return
					if !isRunning: 
						play_anim("walk", "")
						isRunning = false
					elif isRunning: 
						isRunning = true
						play_anim("run", "")
		elif velocity.y < 0: play_anim("jump", "jump")
		elif velocity.y > 0: play_anim("fall", "")
	else:
		if $sideAnimation.current_animation != "": $sideAnimation.current_animation = ""
		animPlayer = $topAnimation
		if topSprites.visible == false: topSprites.set_visible(true)
		if sideSprites.visible == true: sideSprites.set_visible(false)
		if isGrounded and !Abilities.isHitting and !Abilities.isGrabbing:
			if direction == Vector2.ZERO: play_anim("idle", "")
			else: 
				if !isRunning: 
					if direction.x == 0:
						if direction.y == 1: play_anim("walk_down", "")
						elif direction.y == -1: play_anim("walk_up", "")
					elif direction.x > 0: 
						if direction.y == 0: play_anim("walk_right", "")
						elif direction.y > 0: play_anim("walk_downRight", "")
						elif direction.y < 0: play_anim("walk_upRight", "")
					elif direction.x < 0: 
						if direction.y == 0: play_anim("walk_left", "")
						elif direction.y > 0: play_anim("walk_downLeft", "")
						elif direction.y < 0: play_anim("walk_upLeft", "")
				elif isRunning:
					if direction.x == 0:
						if direction.y == 1: play_anim("run_down", "")
						elif direction.y == -1: play_anim("run_up", "")
					elif direction.x > 0: 
						if direction.y == 0: play_anim("run_right", "")
						elif direction.y > 0: play_anim("run_downRight", "")
						elif direction.y < 0: play_anim("run_upRight", "")
					elif direction.x < 0: 
						if direction.y == 0: play_anim("run_left", "")
						elif direction.y > 0: play_anim("run_downLeft", "")
						elif direction.y < 0: play_anim("run_upLeft", "")
	
	
func reset_speed():
	if Global.moveType != Global.moveTypes.TOP: speed = speeds.WALK
	else: speed = speeds.TOP
	
func _input(_event):
	if Input.is_action_just_pressed("notif"): create_notif()
	if Input.is_action_just_pressed("drop"): if items_in_hand != []: set_down()
	if Input.is_action_pressed("run") and isGrounded: 
		isRunning = true
		speed = speeds.RUN
	elif Input.is_action_just_released("run"): 
		isRunning = false
		reset_speed()
	elif Input.is_action_just_released("run"): reset_speed()
	if Input.is_action_just_pressed("hit"): hit()
	elif Input.is_action_just_pressed("use_ability"): use_ability()
	elif Input.is_action_pressed("interact"):
		speed = speeds.SLOW
		if Input.is_action_just_pressed("sav_down"): grab()
		if Input.is_action_just_released("sav_down"): ungrab("set_down")
	elif Input.is_action_just_pressed("change_ability"): Abilities.change_current_ability()
	
	if Input.is_action_just_released("use_ability"): deactivate_ability()
	if Input.is_action_just_released("hit"): Abilities.isHitting = false
	if Input.is_action_just_released("interact"): reset_speed()

func use_ability() -> void:
	match Abilities.current_ability:
		Abilities.abilities.NONE: 
			print("no ability")
			return
		Abilities.abilities.LAUNCH:
			print("the launch ability doesn't work yet")
		Abilities.abilities.HANG: if isTouchingWall: Abilities.isHanging = true
		Abilities.abilities.TRANSLATE:	translate_ability()
	print("ability activated")


func deactivate_ability() -> void:
	match Abilities.current_ability:
		Abilities.abilities.NONE: pass
		Abilities.abilities.LAUNCH: pass #ungrab("launch")
		Abilities.abilities.HANG: unhang()
		Abilities.abilities.TRANSLATE: untranslate()
	print("ability deactivated")


func translate_ability():
	pass


func untranslate():
	pass


func launch() -> void: 
	if items_in_hand == []: return
	var index = 0
	var item = items_in_hand[index]
	print(item.name, " launched")
	item.get_parent().remove_child(item)
	get_parent().add_child(item)
	item.position = position
	if item is RigidBody2D: 
		item.set_mode(RigidBody2D.MODE_RIGID)
		item.collision.set_deferred("disabled", false)
		item.pickupTimer.start()
		item.continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	item = null


func ungrab(followup) -> void:
	Abilities.isGrabbing = false
	reset_speed()
	match followup: 
		"set_down": set_down()
		"launch": launch()


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
	if Abilities.isGrabbing: return 	
	if Global.moveType == Global.moveTypes.TOP: return
	var sprites : Array = []
	for i in spriteGroup32: sprites.append(i)
	for i in spriteGroup8: sprites.append(i)
	if direction.x > 0.0 and isFacingRight:
		for sprite in sprites:
			sprite.flip_h = false
			isFacingRight = false
	elif direction.x < 0.0 and !isFacingRight:
		for sprite in sprites:
			sprite.flip_h = true
			isFacingRight = true
	if isFacingRight:
		pickupSpot.position.x = -9
		ray.set_cast_to(-closeVector)
		return
	pickupSpot.position.x = +3
	ray.set_cast_to(closeVector)


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
			if abs(collision.normal.x) == 1:
				isTouchingWall = true
				if Input.is_action_pressed("use_ability") and Abilities.current_ability == Abilities.abilities.HANG: Abilities.isHanging = true
			else:
				isTouchingWall = false


func set_down():
	if items_in_hand == []: return
	var item = items_in_hand[0]
	item.get_parent().remove_child(item)
	get_parent().add_child(item)
	item.position = position
	if item is RigidBody2D: 
		item.set_mode(RigidBody2D.MODE_RIGID)
		item.collision.set_disabled(false)
		item.pickupTimer.start()
		item.continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	items_in_hand.remove(0)
	print(items_in_hand)
	

func pickup_item(item):
	if items_in_hand.has(item) or items_in_hand.size() >= 1: 
		print("hands are full")
		return
	items_in_hand.append(item)
	item.get_parent().remove_child(item)
	pickupSpot.add_child(item)
	if item is RigidBody2D: 
		item.set_mode(RigidBody2D.MODE_STATIC)
		item.collision.set_disabled(true)
		item.continuous_cd = RigidBody2D.CCD_MODE_DISABLED
		item.rotation = 0
	item.position = pickupSpot.position


func create_notif():
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
	if Global.orbs > 0 and Abilities.canLaunch: spark(false)
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
		pickup_item(collider)


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
	if gravityShift != Vector2.ZERO: velocity.x *= gravityShift.x
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
	if gravityShift != Vector2.ZERO:
		velocity.y *= gravityShift.y
	return velocity.y


func get_cur_time() -> float: return OS.get_ticks_msec() / 1000.0

  

