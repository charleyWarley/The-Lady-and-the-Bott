extends Node

enum abilities { NONE, REACH, HANG, STOMP }
var ability = abilities.NONE

var canReach := false
var canHang := false
var canStomp := false
var isStomping := false
var isHanging := false
var isGrabbing := false

var isHitting := false
var hasTool := false


func change_ability():
	match ability:
		abilities.NONE: 
			if canReach: ability = abilities.REACH
			elif canHang: ability = abilities.HANG
			elif canStomp: ability = abilities.STOMP
			else: print("no abilities available")
		abilities.REACH:
			if canHang: ability = abilities.HANG
			elif canStomp: ability = abilities.STOMP
			else: print("REACH")
		abilities.HANG:
			if canStomp: ability = abilities.STOMP
			elif canReach: ability = abilities.REACH
			else: print("HANG")
		abilities.STOMP:
			if canReach: ability = abilities.REACH
			elif canReach: ability = abilities.HANG
			else: print("STOMP")
