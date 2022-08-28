extends Camera2D

var isLimitSet = false
var target = null
var isTargetSet = false
var maxLimit
var minLimit
var xLimitMax
var yLimitMax
var xLimitMin
var yLimitMin
var drag
var targetPosition

onready var animPlayer = $AnimationPlayer


func _on_star_collected(ability):
	print(ability, " star collected")
	animPlayer.play("star_collected")


func _on_camera_shake(intensity): #executed when something shakes the camera
	if intensity > 12: intensity = 12
	var shake = animPlayer.get_animation("shake") #set shake to the animation called shake
	#set the values of the animation tracks of shake
	shake.track_set_key_value(0, 0, 0.5 * intensity)
	shake.track_set_key_value(0, 1, -0.6 * intensity)
	shake.track_set_key_value(0, 2, 0.2 * intensity)
	shake.track_set_key_value(0, 3, 0 * intensity)
	animPlayer.play("shake") #play the animation


func _physics_process(_delta) -> void:
	if !target: return
	set_targetPosition()
	if !isTargetSet: set_target()
	position = lerp(position, targetPosition, drag)

func set_target():
	target.connect("camera_shake", self, "_on_camera_shake")
	isTargetSet = true
	position = targetPosition
	drag = 0.035

func set_targetPosition():
	#set the camera to follow the target and set the limits of the camera
		if target.isFacingRight: targetPosition = target.position
		else: targetPosition = target.position
	
		#if target.isFlipped: targetPosition = Vector2(target.position.x + 760, target.position.y + 340)
		#else: targetPosition = Vector2(target.position.x + 690, target.position.y + 340)
