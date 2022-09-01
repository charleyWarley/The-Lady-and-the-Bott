extends StaticBody2D


export(PackedScene) onready var prize
export(bool) var isInvisible = false
onready var collisionShape = $CollisionShape2D
onready var sprite = $Sprite
onready var animPlayer = $AnimationPlayer
onready var barrier = $CollisionShape2D

func _ready():
	add_to_group("breakable")
	if isInvisible: 
		collisionShape.set_disabled(true)
		sprite.set_visible(false)
	else: 
		sprite.set_visible(true)
		collisionShape.set_disabled(false)

func show_prize(newPrize):
	if isInvisible: 
		collisionShape.set_disabled(false)
		sprite.set_visible(true)
	get_parent().add_child(newPrize)
	newPrize.position = self.position
	newPrize.position.y -= 32
	newPrize.emit_signal("collected")
	animPlayer.play("hit")

func destroy():
	print("destroyed")
	var newPrize = prize.instance()
	show_prize(newPrize)
	$AnimationPlayer.play("hit")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "hit": 
		barrier.set_one_way_collision(true)
		animPlayer.play("collected")
