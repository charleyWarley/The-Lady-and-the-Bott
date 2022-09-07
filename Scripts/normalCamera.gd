extends Camera2D

var isLimitSet = false
var target = null
var isTargetSet = false
var maxLimit : Vector2
var minLimit : Vector2
var drag
var targetPosition

onready var shakeTimer = $shakeTimer
onready var tween = $Tween
var isShaking = false
var shakeAmount = 0
var normal_offset = offset
var shake_offset = Vector2.ZERO

func _on_star_collected(ability):
	print(ability)
	shake(100)

func shake(new_shake, shake_time = 0.4, shake_limit = 100):
	return
	shakeAmount += new_shake
	if shakeAmount > shake_limit:
		shakeAmount = shake_limit
	shakeTimer.wait_time = shake_time
	tween.stop_all()
	set_process(true)
	shakeTimer.start()
	print("camera should shake with ", shakeAmount, " intensity")

func _ready():
	set_process(false)
	
func _process(delta):
	isShaking = true
	shake_offset = (Vector2(rand_range(-shakeAmount, shakeAmount), rand_range(shakeAmount, -shakeAmount)) * delta * 10 + normal_offset)
	
func _physics_process(delta) -> void:
	if !target: return
	if !isTargetSet: set_target()
	if isShaking: return
	set_targetPosition()
	position = lerp(position, targetPosition, drag * delta)

func set_target():
	isTargetSet = true
	drag = 1.6

func set_targetPosition():
	if Input.is_action_pressed("sav_up") and Global.moveType != Global.moveTypes.TOP and target.isGrounded: 
		normal_offset.y =  -(get_viewport_rect().size.y * 0.35)
	elif Input.is_action_pressed("sav_down") and Global.moveType != Global.moveTypes.TOP and target.isGrounded: 
		normal_offset.y =  +(get_viewport_rect().size.y * 0.2)
	else: 
		normal_offset.y = -(get_viewport_rect().size.y * 0.15)
	if !target.isFacingRight: normal_offset.x = (get_viewport_rect().size.x * 0.15)
	else: normal_offset.x =  -(get_viewport_rect().size.x * 0.15)
	targetPosition = Vector2(target.position.x + normal_offset.x + shake_offset.x, target.position.y + normal_offset.y + shake_offset.y)
	
	if targetPosition.x < minLimit.x: targetPosition.x = minLimit.x
	if targetPosition.x > maxLimit.x: targetPosition.x = maxLimit.x
	if targetPosition.y < minLimit.y: targetPosition.y = minLimit.y
	if targetPosition.y > maxLimit.y: targetPosition.y = maxLimit.y

func _input(event):
	if Input.is_action_pressed("zoom"): zoom = Vector2(20,20)
	if Input.is_action_just_released("zoom"): zoom = Vector2(1,1)	


func _on_shakeTimer_timeout():
	shakeAmount = 0
	isShaking = false
	set_process(false)
	tween.interpolate_property(self, "shake_offset", shake_offset, Vector2.ZERO, 0.01, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
