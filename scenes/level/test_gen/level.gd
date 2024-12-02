extends Level

@export var first_room_scene = preload("res://scenes/level/test_gen/level_rooms/0 - start room.tscn")
@export var room_list: Array[PackedScene]
@export var level_depth: int
@export var rooms: Node3D

var current_room: Room
var new_room: Room
var current_room_connector_node: Connector
var new_room_connector_node: Connector

@export var room_id_list: Array[int]
@export var room_transform_list: Array[Transform3D]


func ready():
	var first_room: Room = first_room_scene.instantiate()
	rooms.add_child(first_room)
	current_room = first_room
	if multiplayer.is_server():
		generate_room()
	else:
		$levelSynchronizer.synchronized.connect(generate_level_from_data)


func on_level_finished_generating():
	level_finished_loading.emit()


func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("interact"):
		#if current_room == null:
			#current_room = rooms.get_child(0)
		#generate_room()
	pass


func generate_room():
	var new_room_id = randi() % room_list.size()
	var new_room_scene = room_list[new_room_id]
	new_room = new_room_scene.instantiate()
	new_room.room_id = new_room_id

	current_room_connector_node = get_unused_connector(current_room)
	new_room_connector_node = get_unused_connector(new_room)
	new_room.room_loaded.connect(reorient_room)

	new_room.name = "Room %s" % rooms.get_child_count()
	rooms.add_child(new_room)


func get_unused_connector(room: Room) -> Connector:
	var unused_connectors := []
	for connector: Connector in room.connectors.get_children():
		if connector.open:
			unused_connectors.append(connector)
			
	return unused_connectors[randi() % room.connectors.get_child_count()-1]


func reorient_room():
	var current_room_direction_node: Marker3D = current_room_connector_node.get_child(0)
	var new_room_direction_node: Marker3D = new_room_connector_node.get_child(0)

	var current_room_connector_direction: Vector3 = current_room_connector_node.global_position.direction_to(current_room_direction_node.global_position)
	var new_room_connector_direction: Vector3 = new_room_connector_node.global_position.direction_to(new_room_direction_node.global_position)

	# Rotate room by difference in connector directions so they are facing the same direction
	var atan_c = atan2(current_room_connector_direction.z, current_room_connector_direction.x)
	var atan_n = atan2(new_room_connector_direction.z, new_room_connector_direction.x)
	var atan_func =  atan_n - atan_c
	new_room.rotate_y(atan_func)

	# Flip so it's the opposite direction
	new_room.rotate_y(deg_to_rad(180))

	# Move new room to current room connector position, offset by new room connector
	new_room.global_position = current_room_connector_node.global_position - new_room_connector_node.global_position

	# disable used connectors
	current_room_connector_node.open = false
	new_room_connector_node.open = false
	
	current_room = new_room
	
	# Add info to generated level data
	room_id_list.append(new_room.room_id)
	room_transform_list.append(new_room.global_transform)
	
	if rooms.get_children().size() <= level_depth:
		generate_room()
	else:
		on_level_finished_generating()

		
func generate_level_from_data():
	$levelSynchronizer.synchronized.disconnect(generate_level_from_data)
	var index = 0
	for room in room_id_list:
		var room_scene = room_list[room]
		new_room = room_scene.instantiate()
		rooms.add_child(new_room)
		new_room.global_transform = room_transform_list[index]
		index += 1

	on_level_finished_generating()

func print_stats():
	Console.write(multiplayer.get_unique_id())
	for room in room_id_list:
		var message = "%s \n %s" % [room_id_list[room], room_transform_list[room].origin]

		Console.write(message)
		print(message)
