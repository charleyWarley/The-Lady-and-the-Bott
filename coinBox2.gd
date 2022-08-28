extends StaticBody2D

var prize setget set_prize
export(bool) var isInvisible = false
onready var collisionShape = $CollisionShape2D
onready var sprite = $Sprite
onready var animPlayer = $AnimationPlayer

func _ready():
	if isInvisible: 
		collisionShape.set_disabled(true)
		sprite.set_visible(false)
	else: 
		sprite.set_visible(true)
		collisionShape.set_disabled(false)

func set_prize(newPrize):
	if isInvisible: 
		collisionShape.set_disabled(false)
		sprite.set_visible(true)
	prize = newPrize
	get_parent().add_child(newPrize)
	newPrize.position = self.position
	newPrize.position.y -= 32
	newPrize.emit_signal("collected")
	animPlayer.play("hit")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "hit": animPlayer.play("collected")
