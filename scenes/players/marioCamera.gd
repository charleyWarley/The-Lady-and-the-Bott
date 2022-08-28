extends Camera2D

var drag = 0.015
var t = 0.4
var dragMargin_right = 0.7
var rightLimit = 10000000

var screenSize

export(NodePath) onready var target = get_node(target)


func _ready():
	screenSize = self.get_viewport_rect().size


func _process(_delta):
	update_camera(target.get_global_position())


func update_camera(character_pos):
	var new_camera_pos = get_global_position()
	var dragArea = self.get_global_position().x + screenSize.x * (drag_margin_right - t)
	
	if character_pos.x > dragArea:
		new_camera_pos.x = character_pos.x - screenSize.x * (drag_margin_right - t)
	new_camera_pos = lerp(get_global_position(), new_camera_pos, drag)
	self.set_global_position(new_camera_pos)
