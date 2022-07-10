extends Camera2D

var target = null
var isSet = false
var xLimitMax
var yLimitMax
var xLimitMin
var yLimitMin
var drag
var targetPosition

onready var animPlayer = $AnimationPlayer

#executed when something shakes the camera
func _on_camera_shake(intensity):
	print("shake intensity: ", intensity)
	if intensity > 12: intensity = 12
	
	#set shake to the animation called shake
	var shake = animPlayer.get_animation("shake")
	
	#set the values of the animation tracks of shake
	shake.track_set_key_value(0, 0, 0.5 * intensity)
	shake.track_set_key_value(0, 1, -0.6 * intensity)
	shake.track_set_key_value(0, 2, 0.2 * intensity)
	shake.track_set_key_value(0, 3, 0 * intensity)
	
	#play the animation
	animPlayer.play("shake")


func set_targetPosition():
	#set the camera to follow the target and set the limits of the camera
	match Global.players:
		"single":
			xLimitMax = 250
			yLimitMax = 400
			xLimitMin = -200
			yLimitMin = -143
			drag = 0.035
			if target.isFlipped:
				targetPosition = Vector2(target.position.x + 760, target.position.y + 340)
			else:
				targetPosition = Vector2(target.position.x + 690, target.position.y + 340)
		"multi":
			xLimitMax = 2500
			yLimitMax = 600
			xLimitMin = -300
			yLimitMin = -143
			drag = 0.085
			if target.isFlipped:
				targetPosition = Vector2(target.position.x + 690, target.position.y + 340)
			else:
				targetPosition = Vector2(target.position.x + 660, target.position.y + 340)
	
	
func _physics_process(_delta) -> void:
	#ignore the rest if there's no target for the camera
	if !target:
		return
	set_targetPosition()
	
	#follow the target
	if !isSet: 
		isSet = true
		position = targetPosition
	else: 
		if targetPosition.x < xLimitMin: targetPosition.x = xLimitMin
		if targetPosition.y < yLimitMin: targetPosition.y = yLimitMin
		if targetPosition.y > yLimitMax: targetPosition.y = yLimitMax
		if targetPosition.x > xLimitMax: targetPosition.x = xLimitMax
		position = lerp(position, targetPosition, drag)
