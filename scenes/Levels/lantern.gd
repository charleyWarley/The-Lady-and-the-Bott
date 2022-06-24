extends RigidBody2D

export(NodePath) onready var light = get_node(light) as Light2D
export(NodePath) onready var collision = get_node(collision) as CollisionShape2D

func _ready():
	add_to_group("boxes")


func _on_Area2D_body_entered(body):
	if body.name != "saviya": return
	call_deferred("set_grabbed", body)
	$Area2D.queue_free()

func set_grabbed(body):
	get_parent().remove_child(self)
	body.pos2D.add_child(self)
	set_mode(RigidBody2D.MODE_STATIC)
	print(get_mode())
	collision.set_disabled(true)
	continuous_cd = RigidBody2D.CCD_MODE_DISABLED
	rotation = 0
	position = get_parent().position
