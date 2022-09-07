extends Node

enum moveTypes { TOP, SIDE, MARIO }
var moveType = moveTypes.TOP setget set_moveType, get_moveType
var graphicStyle := "8"
var orbs = 0
var jumps = 0
var players = ""

var lady

var overWorld = null
var levelOne = null
var marioWorld = null
var camera = null

func define_level(name, level):
	match name:
		"overWorld": 
			graphicStyle = "8"
			overWorld = level
		"levelOne": 
			graphicStyle = "32"
			levelOne = level
		"marioWorld": 
			graphicStyle = "8"
			marioWorld = level
	
func set_moveType(newType): moveType = newType

func get_moveType(): return moveType

func set_level(newLevel): var _isLevelSet = get_tree().change_scene_to(newLevel)
