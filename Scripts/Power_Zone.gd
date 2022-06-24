extends Area2D

var isPoweredOn = false
var isStarCreated = false
export var ability : String
export(PackedScene) onready var star
export(NodePath) onready var light = get_node(light) as Light2D
export(NodePath) onready var particle = get_node(particle) as CPUParticles2D
export(NodePath) onready var lever = get_node(lever) as Area2D
export(NodePath) onready var sensor = get_node(sensor) as ColorRect
export(NodePath) onready var starPos = get_node(starPos) as Position2D

func _on_powered_on():
	if ability == "hang":
		print("light turned on")
		light.visible = true
	isPoweredOn = true
	particle.set_emitting(true)


func _on_powered_off():
	if ability == "hang":
		print("light turned off")
		light.visible = false
	isPoweredOn = false
	sensor.set_visible(false)
	particle.set_emitting(false)


func _ready():
	particle.set_emitting(false)
	lever.connect("powered_on", self, "_on_powered_on")
	lever.connect("powered_off", self, "_on_powered_off")


func _physics_process(_delta):
	var bodies = get_overlapping_bodies()
	if bodies == []: sensor.set_visible(false)
	for body in bodies:
		match body.name:
			"alizea":
				if isPoweredOn:
					sensor.set_visible(true)
					if Input.is_action_just_pressed("ali_down") and isStarCreated == false:
						isStarCreated = true
						var newStar = star.instance()
						starPos.add_child(newStar)
						newStar.ability = ability
			"saviya":
				if particle.emitting: body.isDead = true
				
