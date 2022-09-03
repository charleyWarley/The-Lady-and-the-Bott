extends Node2D

const ICONS = {
	"none": preload("res://sprites/icons/heart_empty.png"),
	"reach": preload("res://sprites/icons/heart.png"),
	"hang": preload("res://sprites/icons/wand.png"),
	"stomp": preload("res://sprites/icons/arrow_diamond.png")
}

onready var sprite = $Sprite

var last_icon
var curr_icon


func check_icon():
	print("check started")
	match Abilities.ability:
		Abilities.abilities.NONE: change_icon("none")
		Abilities.abilities.REACH: change_icon("reach")
		Abilities.abilities.HANG: change_icon("hang")
		Abilities.abilities.STOMP: change_icon("stomp")



func change_icon(newIcon):
	curr_icon = newIcon
	if curr_icon == last_icon: 
		print("icon stayed the same")
		return
	print("icon changed from", last_icon, " to ", curr_icon)
	sprite.set_texture(ICONS[newIcon])
	last_icon = curr_icon


func _ready():
	check_icon()


func _process(_delta):
	if Input.is_action_just_pressed("change_ability"): 
		print("checking ability icon")
		check_icon()
