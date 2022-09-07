extends Node2D

var room = preload("res://scenes/Levels/room.tscn")
var font = preload("res://fonts/Fonts/Uni_Unlit.tres")

var tile_size = 16
var num_rooms = 50
var min_size = 8
var max_size = 20
var hspread = 400
var cull = 0.5
var room_positions = []
var path
var start_room = null
var end_room = null
var play_mode = true
var player = null

onready var map = $tileMapChunk

func _ready():
	make_rooms()

func make_rooms():
	randomize()
	for _i in range(num_rooms):
		var pos = Vector2(rand_range(-hspread, hspread), 0)
		var r = room.instance()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.make_room(pos, Vector2(w, h) * tile_size)
		$rooms.add_child(r)
	#yield(get_tree(), "idle_frame")
	make_timer(0.2, "_cull_rooms")


func _cull_rooms():
	room_positions = []
	for r in $rooms.get_children():
		if randf() < cull: r.queue_free()
		else: 
			r.mode = RigidBody2D.MODE_STATIC
			room_positions.append(Vector3(r.position.x, r.position.y, 0))
	make_timer(0.3, "set_mst")


func set_mst():
	path = find_mst(room_positions)
	make_timer(0.3, "make_map")
	#make_map(
	player = Global.lady
	player.get_parent().remove_child(player)
	add_child(player)
	yield(get_tree().create_timer(1.1), "timeout")
	player.position = start_room.position + Vector2(64, -64)
	var collision = player.move_and_collide(Vector2(position.x +1, position.y+1), false, true, true)
	if collision: make_map()

func find_mst(nodes):
	#prim's algorithm
	path = AStar.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	while nodes:
		var min_dist = INF
		var min_pos = null
		var curr_pos = null
		for pos1 in path.get_points():
			pos1 = path.get_point_position(pos1)
			for pos2 in nodes: 
				if pos1.distance_to(pos2) < min_dist:
					min_dist = pos1.distance_to(pos2)
					min_pos = pos2
					curr_pos = pos1
		var neighbor = path.get_available_point_id()
		path.add_point(neighbor, min_pos)
		path.connect_points(path.get_closest_point(curr_pos), neighbor)
		nodes.erase(min_pos)
	return path
	
func make_map():
	map.clear()
	find_start_room()
	find_end_room()
	#fill map
	var full_rect = Rect2()
	for i in $rooms.get_children():
		var rect = Rect2(i.position - i.size, i.get_node("CollisionShape2D").shape.extents * 2)
		full_rect = full_rect.merge(rect)
	var topLeft = map.world_to_map(full_rect.position)
	var bottomRight = map.world_to_map(full_rect.end)
	for x in range(topLeft.x, bottomRight.x):
		for y in range(topLeft.y, bottomRight.y):
			map.set_cell(x, y, 0)
	
	#carve rooms
	var corridors = [] #one corridor per connection
	for i in $rooms.get_children():
		var room_size = (i.size / tile_size).floor()
		#var room_pos = map.world_to_map(i.position)
		var upperLeft = (i.position / tile_size).floor() - room_size
		for x in range(2, room_size.x * 2 - 1):
			for y in range(2, room_size.y * 2 - 1):
				map.set_cell(upperLeft.x + x, upperLeft.y + y, -1)
		#carve corridors
		var point = path.get_closest_point(Vector3(i.position.x, i.position.y, 0))
		for conn in path.get_point_connections(point):
			if not conn in corridors:
				var start = map.world_to_map(Vector2(path.get_point_position(point).x, path.get_point_position(point).y))
				var end = map.world_to_map(Vector2(path.get_point_position(conn).x, path.get_point_position(conn).y))
				carve_path(start, end)
		corridors.append(point)


func carve_path(pos1, pos2):
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: x_diff = pow(-1, randi() % 2)
	if y_diff == 0: y_diff = pow(-1, randi() % 2)
	var x_y = pos1
	var y_x = pos2
	if (randi() % 2) > 0:
		x_y = pos2
		y_x = pos1
	for x in range(pos1.x, pos2.x, x_diff):
		map.set_cell(x, x_y.y, 1)
		map.set_cell(x, x_y.y + y_diff, 1)
	for y in range(pos1.y, pos2.y, y_diff):
		map.set_cell(y_x.x, y, 1)
		map.set_cell(y_x.x + x_diff, y, 1)





func _draw():
	if start_room: draw_string(font, start_room.position - Vector2(125, 0), "start", Color.white)
	if end_room: draw_string(font, end_room.position - Vector2(125, 0), "end", Color.white)
	#if !play_mode:
	#	for r in $rooms.get_children():
	#		draw_rect(Rect2(r.position - r.size, r.size * 2),
	#		Color(32, 228, 0), false)
	#	if path:
	#		for node in path.get_points():
	#			for conn in path.get_point_connections(node):
	#				var node_pos = path.get_point_position(node)
	#				var conn_pos = path.get_point_position(conn)
	#				draw_line(Vector2(node_pos.x, node_pos.y), Vector2(conn_pos.x, conn_pos.y), Color(1, 1, 0), 15, true)

func _process(_delta):
	update()


func _input(event):
	if event.is_action_pressed("help"):
		for n in $rooms.get_children():
			n.queue_free()
		path = null
		start_room = null
		end_room = null
		make_rooms()
	if event.is_action_pressed("zoom"): play_mode = false
	else: play_mode = true


func make_timer(time: float, method: String):
	var timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(time)
	timer.one_shot = true
	timer.connect("timeout", self, method)
	timer.start()
	#remember to delete the timer when in times out ~ i dont wanna do it yet lol


func find_start_room():
	var min_x = 0
	for r in $rooms.get_children():
		if r.position.x < min_x:
			start_room = r
			min_x = r.position.x


func find_end_room():
	var max_x = 0
	for r in $rooms.get_children():
		if r.position.x > max_x:
			end_room = r
			max_x = r.position.x
