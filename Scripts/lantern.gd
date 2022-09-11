extends RigidBody2D

const SOUNDS = {
	"pickup": preload("res://audio/sfx/hitObject.wav")
}


export(NodePath) onready var light = get_node(light) as Light2D
export(NodePath) onready var collision = get_node(collision) as CollisionShape2D
export(PackedScene) onready var collect_area
export(NodePath) onready var pickupTimer = get_node(pickupTimer) as Timer
onready var sfx = $sfx
var area


func _on_collectArea_body_entered(body):
	if body.name != "lady": return
	if body.items_in_hand != []: return
	body.call_deferred("pickup_item", self)
	area.queue_free()
	area = null
	play_snd("pickup")

func _ready():
	var newArea = collect_area.instance() as Area2D
	area = newArea
	newArea.position = Vector2.ZERO
	newArea.connect("body_entered", self, "_on_collectArea_body_entered")
	add_child(newArea)
	add_to_group("boxes")
	set_visible(true)
	

func play_snd(snd) -> void:
	if SOUNDS.has(snd):
		if !sfx.is_playing():
			sfx.stream = SOUNDS[snd]
			sfx.play()


func _on_Timer_timeout():
	var newArea = collect_area.instance()
	area = newArea
	newArea.connect("body_entered", self, "_on_collectArea_body_entered")	
	newArea.position = Vector2.ZERO
	add_child(newArea)
