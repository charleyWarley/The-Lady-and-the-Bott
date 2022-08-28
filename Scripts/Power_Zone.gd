extends Area2D

var isPoweredOn = false
var isStarCreated = false
export var ability : String
export(PackedScene) onready var star
export(NodePath) onready var particle = get_node(particle) as CPUParticles2D
export(NodePath) onready var lever = get_node(lever) as Area2D
export(NodePath) onready var sensor = get_node(sensor) as ColorRect
export(NodePath) onready var starPos = get_node(starPos) as Position2D

func _on_switch_flipped(isSwitchPoweredOn):
	isPoweredOn = isSwitchPoweredOn
	particle.set_emitting(isPoweredOn)
	sensor.set_visible(isPoweredOn)


func _ready():
	particle.set_emitting(false)
	lever.connect("switch_flipped", self, "_on_switch_flipped")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name != "on": return
	if isStarCreated: return
	isStarCreated = true
	var newStar = star.instance()
	starPos.add_child(newStar)
	newStar.ability = ability
	print(newStar.ability, " star created")
