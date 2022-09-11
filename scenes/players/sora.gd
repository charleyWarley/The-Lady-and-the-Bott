extends RigidBody2D

onready var animPlayer = $AnimationPlayer
onready var sprite8 = $"8-bit-sprite"
onready var sprite32 = $"32-bit-sprite"
var velocity : Vector2
var speed = 1
var drag = 0.25
var isTurning = false
var isGrounded = true

enum drags {
	TURN = 99
	AIR = 80
	BASIC = 80
	STOP = 100
}

func _physics_process(delta):
	var direction : Vector2
	rotation = 0
	if Input.is_action_pressed("sav_left"): direction.x = -1
	if Input.is_action_pressed("sav_right"): direction.x = 1
	if Global.moveType == Global.moveTypes.TOP:
		if Input.is_action_pressed("sav_down"): direction.y = 1
		if Input.is_action_pressed("sav_up"): direction.y = -1
	else:
		direction.y = 1
	set_velocity(direction, delta)
	check_anim(direction)


func set_velocity(direction, delta):
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
			elif sign(horizontal_move) != sign(velocity.x) and sign(vertical_move) != sign(velocity.y):
				isTurning = true
				drag = float(drags.TURN)
			else:
				isTurning = false
				drag = float(drags.BASIC)
	else:
		isTurning = false
		drag = float(drags.BASIC)
	drag *= 0.01
	direction = direction.normalized()
	velocity += direction * speed
	velocity *= pow(1 - drag, delta * 10)
	apply_central_impulse(velocity)

func check_anim(direction):	
	if Global.graphicStyle == "8": 
		sprite8.set_visible(true)
		sprite32.set_visible(false)
	else:
		sprite32.set_visible(true)
		sprite8.set_visible(false)
	if direction.x > 0:
		if direction.y > 0: play_anim("walk_DownRight", "")
		elif direction.y < 0: play_anim("walk_UpRight", "")
		elif direction.y == 0: play_anim("walk_DownRight", "")
	elif direction.x < 0:
		if direction.y > 0: play_anim("walk_DownLeft", "")
		elif direction.y < 0: play_anim("walk_UpLeft", "")
		elif direction.y == 0: play_anim("walk_DownLeft", "")
	elif direction.x == 0:
		if direction.y > 0: play_anim("walk_DownLeft", "")
		elif direction.y < 0: play_anim("walk_UpRight", "")
		elif direction.y == 0: play_anim("idle", "")


func play_anim(anim: String, _snd: String):
	if anim == animPlayer.current_animation: return
	animPlayer.play(anim)
