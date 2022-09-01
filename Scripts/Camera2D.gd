extends Camera2D

var isLimitSet = false
var target = null
var isTargetSet = false
var maxLimit : Vector2
var minLimit : Vector2
var drag
var targetPosition
var isShaking = false
onready var animPlayer = $AnimationPlayer
export(NodePath) onready var loading = get_node(loading)

func _on_star_collected(ability):
	print(ability)
	animPlayer.play("star_collected")


func _on_camera_shake(intensity): #executed when something shakes the camera
	isShaking = true
	if intensity > 12: intensity = 12
	var shake = animPlayer.get_animation("shake") #set shake to the animation called shake
	#set the values of the animation tracks of shake
	shake.track_set_key_value(0, 0, 0.5 * intensity)
	shake.track_set_key_value(0, 1, -0.6 * intensity)
	shake.track_set_key_value(0, 2, 0.2 * intensity)
	shake.track_set_key_value(0, 3, 0 * intensity)
	animPlayer.play("shake") #play the animation
	
func _physics_process(delta) -> void:
	if !target: return
	if !isTargetSet: set_target()
	if isShaking: return
	set_targetPosition()
	position = lerp(position, targetPosition, drag * delta)

func set_target():
	target.connect("camera_shake", self, "_on_camera_shake")
	isTargetSet = true
	drag = 1.6

func set_targetPosition():
	var offSet : Vector2
	if Input.is_action_pressed("sav_up") and Global.moveType != Global.moveTypes.TOP: offSet.y =  -(get_viewport_rect().size.y * 0.35)
	elif Input.is_action_pressed("sav_down") and Global.moveType != Global.moveTypes.TOP: offSet.y =  +(get_viewport_rect().size.y * 0.2)
	else: offSet.y = -(get_viewport_rect().size.y * 0.1)
	
	if target.isFacingRight: offSet.x = (get_viewport_rect().size.x * 0.2)
	else: offSet.x =  -(get_viewport_rect().size.x * 0.2)
	
	targetPosition = Vector2(target.position.x + offSet.x, target.position.y + offSet.y)
	
	
	if targetPosition.x < minLimit.x: targetPosition.x = minLimit.x
	if targetPosition.x > maxLimit.x: targetPosition.x = maxLimit.x
	if targetPosition.y < minLimit.y: targetPosition.y = minLimit.y
	if targetPosition.y > maxLimit.y: targetPosition.y = maxLimit.y
	
	if loading.is_visible() and target.is_visible(): loading.set_visible(false)



func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "shake": isShaking = false
