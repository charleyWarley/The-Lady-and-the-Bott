extends Area2D

var canOpen = false
var isOpen = false
var isOpening = false

onready var lever = $DoorLever
onready var anim_player = $AnimationPlayer


func _ready() ->  void:
	play_anim("close")

func _physics_process(_delta) -> void:
	if isOpen: $CollisionShape2D.set_disabled(true)
	else: $CollisionShape2D.set_disabled(false)
	if isOpening: 
		isOpening = false
		isOpen = true
		play_anim("open")


	
func play_anim(anim) -> void:
	if anim_player.current_animation == anim: return
	else: anim_player.play(anim)
