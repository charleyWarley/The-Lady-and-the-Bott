extends RigidBody2D

const SOUNDS = {
	"pickup": preload("res://audio/hitObject.wav")
}


export(NodePath) onready var light = get_node(light) as Light2D
export(NodePath) onready var collision = get_node(collision) as CollisionShape2D

onready var sfx = $sfx



func _on_Area2D_body_entered(body):
	if body.name != "lady": return
	call_deferred("set_grabbed", body)
	play_snd("pickup")
	$collectArea.queue_free()

func _ready():
	add_to_group("boxes")
	set_visible(true)
	

func play_snd(snd) -> void:
	if SOUNDS.has(snd):
		if !sfx.is_playing():
			sfx.stream = SOUNDS[snd]
			sfx.play()



func set_grabbed(body):
	get_parent().remove_child(self)
	body.pos2D.add_child(self)
	set_mode(RigidBody2D.MODE_STATIC)
	print(get_mode())
	collision.set_disabled(true)
	continuous_cd = RigidBody2D.CCD_MODE_DISABLED
	rotation = 0
	position = get_parent().position


func _on_lightArea_body_entered(body):
	if body.is_in_group("enemies"): 
		body._on_enemy_alerted(get_parent())


func _on_lightArea_body_exited(body):
	if body.is_in_group("enemies"): 
		body._on_LOS_broken() #line of sight
