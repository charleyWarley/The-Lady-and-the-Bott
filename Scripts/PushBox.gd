extends KinematicBody2D

const JUMP_BUFFER = 0.08

var time_pressed_jump = 0.0
var time_left_ground = 0.0
var last_grounded = false

var box_jump = -20
var speed = 10
var bud_speed2 = 20
var bud_drag = 0.5
var box_drag = 1
var first_jump = -80
var second_jump = -50
var box_grav = -10
var bud_grav = -1
var velo = Vector2()
var follow = false
var jump2 = false

var facing_right = true

var power = 0
var buddy = false 
var empty = true
var grabbed = 0
var jumps = 0

var revealed = false
var power_full = false
var wait0 = 0
var wait1 = 0

const SOUNDS = {
	"walk": preload("res://audio/walksquoosh.wav"),
	"jump0": preload("res://audio/jump0.wav"),
	"jump1": preload("res://audio/jump1.wav"),
	"jump2": preload("res://audio/jump2.wav")
}

onready var anim_player = $AnimationPlayer
onready var player = get_parent().get_node("Player")
onready var fire = $CollisionShape2D_Buddy/Sprite/Particles2D
onready var sfx = $sfx/sfx

var label_wait = 0


func _ready() -> void:
	add_to_group("boxes")
	add_to_group("buddy")
	play_anim("box1")


func _process(_delta) -> void:
	if jumps >= 100:
		power -= 1
		jumps = 0
		


func _physics_process(_delta) -> void:
	var move = Vector2()
	var cur_grounded = is_on_floor()
	if Input.is_action_pressed("bud_left"):
		move.x -= 1
		anim_check()
	elif Input.is_action_pressed("bud_right"):
		move.x += 1
	anim_check()

	if follow:
		pass
	
	var pressed_jump = Input.is_action_just_pressed("bud_up")
	if buddy and revealed:
		if pressed_jump and cur_grounded:
			jump2 = false
			jump()
		elif !last_grounded and cur_grounded and get_cur_time() - time_pressed_jump < JUMP_BUFFER:
			jump2 = false
			jump()
		elif pressed_jump and get_cur_time() - time_left_ground < JUMP_BUFFER:
			jump2 = false
			jump()
		elif pressed_jump and get_cur_time() - time_left_ground > JUMP_BUFFER:
			jump2 = true
			jump()
		else:
			velo.y -= bud_grav
		if cur_grounded and velo.y > 10:
			velo.y = 10

		if cur_grounded:
			if move == Vector2():
				if !empty:
					play_anim("buddy_idle2")
				else:
					play_anim("buddy_idle")
			else:
				if !empty:
					play_anim("walk")
					wait0 += 1
					if wait0 == 30:
						play_snd("walk")
						wait0 = 0
				elif empty:
					play_anim("walk2")
					wait0 += 1
					if wait0 == 40:
						play_snd("walk")
						wait0 = 0
		elif velo.y > 0:
			play_anim("fall")
		elif velo.y < 0:
			play_anim("jump")
	else:
		anim_check()
		if Input.is_action_just_pressed("bud_up"):
			velo.y = box_jump
		else:
			velo.y -= box_grav
	
	move = move.normalized()
	
	if !buddy:
		velo += move * speed - box_drag * Vector2(velo.x, 0)
	elif buddy:
		if power == 0:
			velo += move * speed - bud_drag * Vector2(velo.x, 0)
		if power > 0:
			velo += move * bud_speed2 - bud_drag * Vector2(velo.x, 0)
		 
	velo = move_and_slide(velo, Vector2.UP, false, 4, PI/4, false)

	if move.x > 0.0 and !facing_right:
			flip()
	elif move.x < 0.0 and facing_right:
			flip()
			
	last_grounded = cur_grounded

func jump() -> void:
	power_check()
	if !jump2:
		if power > 0:
			velo.y = first_jump
			play_snd("jump1")
			jumps += 2
			emit()
			print(jumps)
		elif power == 0:
			velo.y = box_jump
			play_snd("jump0")
			
	else:
		if power > 0:
			velo.y = second_jump
			play_snd("jump2")
			emit()
			jumps += 1
			print(jumps)

func get_cur_time() -> float:
	return OS.get_ticks_msec() / 1000.0

func flip() -> void:
	if !buddy:
		return
	else:
		var sprite = $CollisionShape2D_Buddy/Sprite
		sprite.flip_h = !sprite.flip_h
		facing_right = !facing_right


func power_check() -> void:
	print("Power: ", power)
	if power == 0:
		empty = true
		power_full = false
		print("Not enough power")
	elif power == 1:
		empty = false
		print("Power on")
		power_full = false
	elif power > 20:
		power = 20
		empty = false
		print("Power full")
		power_full = true
		
func play_anim(anim) -> void:
	if anim_player.current_animation == anim:
		return
	else:
		anim_player.play(anim)
	
func anim_check() -> void:
	if !empty:
		if !buddy:
			match grabbed:
				0: play_anim("box2")
				1: play_anim("box2_hit1")
				3: play_anim("box2_hit2")
				6: buddy = true
	else:
		if !buddy:
			match grabbed:
				0: play_anim("box1")
				1: play_anim("box1_hit1")
				3: play_anim("box1_hit2")
	match grabbed:
		4:
			buddy = true
			grabbed += 1
		5:
			play_anim("buddy_reveal")
			wait1 += 1
			if wait1 == 70:
				grabbed += 1
				wait1 = 0
				revealed = true


func play_snd(snd) -> void:
	if SOUNDS.has(snd):
		sfx.stream = SOUNDS[snd]
		sfx.play()


func emit() -> void:
	fire.emitting = !fire.emitting
