extends Node2D

func _ready():
	set_visible(false)
	
func _process(_delta):
	match Global.jumps:
		0: $Sprite/AnimationPlayer.play("empty")
		2: $Sprite/AnimationPlayer.play("one")
		3: $Sprite/AnimationPlayer.play("two")
		5: $Sprite/AnimationPlayer.play("three")
		7: $Sprite/AnimationPlayer.play("four")

