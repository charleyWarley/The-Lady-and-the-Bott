extends Camera2D

var drag = 0.065
var dragMargin_right = 0.01
var rightLimit = 10000000

var screenSize

onready var target = Global.lady


func _ready(): screenSize = self.get_viewport_rect().size


func _process(_delta): update_camera(target.get_global_position())


func update_camera(character_pos):
	var new_camera_pos = get_global_position()
	var dragArea = self.get_global_position().x + screenSize.x * dragMargin_right
	if character_pos.x > dragArea:
		new_camera_pos.x = character_pos.x + screenSize.x * dragMargin_right
	new_camera_pos = lerp(get_global_position(), new_camera_pos, drag)
	self.set_global_position(new_camera_pos)
