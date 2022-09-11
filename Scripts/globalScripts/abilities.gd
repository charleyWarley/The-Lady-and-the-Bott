extends Node

enum abilities { NONE, LAUNCH, HANG, TRANSLATE }
var current_ability = abilities.NONE

var canLaunch := false
var canHang := false
var canTranslate := false
var isTranslateing := false
var isHanging := false
var isGrabbing := false

var isHitting := false
var hasTool := false



func change_current_ability() -> void:
	match current_ability:
		abilities.NONE: 
			if canLaunch: current_ability = abilities.LAUNCH
			elif canHang: current_ability = abilities.HANG
			elif canTranslate: current_ability = abilities.TRANSLATE
			else: print("no abilities available")
		abilities.LAUNCH:
			if canHang: current_ability = abilities.HANG
			elif canTranslate: current_ability = abilities.TRANSLATE
			else: print("LAUNCH")
		abilities.HANG:
			if canTranslate: current_ability = abilities.TRANSLATE
			elif canLaunch: current_ability = abilities.LAUNCH
			else: print("HANG")
		abilities.TRANSLATE:
			if canLaunch: current_ability = abilities.LAUNCH
			elif canLaunch: current_ability = abilities.HANG
			else: print("TRANSLATE")
