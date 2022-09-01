extends Node2D


var isStarted := false
var time : int = 0
var start: int = 0
var end: int = 0
onready var timeLabel = $time


func _ready():
	set_visible(false)


func _process(_delta):
	if Global.moveType != Global.moveTypes.MARIO: set_visible(false)
	if !isStarted and (Global.moveType == Global.moveTypes.MARIO): start_time()
	if isStarted:
		if Global.moveType != Global.moveTypes.MARIO: stop_time()
	time = (Time.get_ticks_msec() - start) / 1000
	timeLabel.set_text(str(time))


func start_time():
	start = Time.get_ticks_msec()
	print(start)
	isStarted = true
	set_visible(true)


func stop_time():
	end = Time.get_ticks_msec()
	isStarted = false
	set_visible(false)
