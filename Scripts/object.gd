extends RigidBody2D
class_name Selectable

var hit = 0
var isSelectable = false

var outline = null
onready var anim_player = $AnimationPlayer


func _ready():
	add_to_group("boxes")
	add_to_group("hitable")
	add_to_group("breakable")
	play_anim("idle")


func _physics_process(_delta):
	if isSelectable and !outline:
		print("outline created")
		outline = $Sprite.duplicate()
		add_child(outline)
		outline.set_draw_behind_parent(true)
		outline.set_modulate(Color( 0.57, 0, 1, 1 ))
		outline.scale *= 1.25
	elif !isSelectable and outline:
		outline.queue_free()
		outline = null
	
	if hit == 1:
		play_anim("hit1")
	elif hit == 2:
		play_anim("hit2")
	elif hit >= 3 and hit != 100:
		hit = 100
		play_anim("hit3")



func play_anim(anim):
	if anim == anim_player.current_animation: return
	anim_player.play(anim)
