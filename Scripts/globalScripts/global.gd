extends Node

enum moveTypes { TOP, SIDE, MARIO }
var moveType = moveTypes.TOP setget set_moveType, get_moveType

var orbs = 0
var jumps = 0
var players = ""

var lady

var overWorld
var levelOne
var marioWorld

func define_level(name, level):
	match name:
		"overWorld": overWorld = level
		"levelOne": levelOne = level
		"marioWorld": marioWorld = level
	
func set_moveType(newType): moveType = newType

func get_moveType(): return moveType

func set_level(newLevel): var _isLevelSet = get_tree().change_scene_to(newLevel)
