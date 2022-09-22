extends Node2D

export(String) onready var grhazan
export(String) onready var translated
export(NodePath) onready var label = get_node(label) as Label

func _ready():
	set_process(false)
	label.set_text(grhazan)

func _on_Area2D_body_entered(body):
	if body.name != "lady": return
	set_process(true)

func _on_Area2D_body_exited(body):
	if body.name != "lady": return
	set_process(false)
	
	
func _process(delta):
	if Input.is_action_just_pressed("use_ability") and Abilities.canTranslate:
		match label.get_text():
			translated: 
				label.set_text(grhazan)
			grhazan:
				label.set_text(translated)
