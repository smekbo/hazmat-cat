extends Node

@export var default_level: PackedScene = load("res://scenes/level/test/level.tscn")

@onready var player_scene: PackedScene = load("res://scenes/player/player.tscn")
@onready var players: Node = $Players

var level : Level


func _ready() -> void:
	load_level(default_level)


func add_host():
	level = $Level
	add_player(1)


func add_player(id: int):
	var spawn_point = level.spawn_points.get_child(randi() % level.spawn_points.get_child_count())
	var player = player_scene.instantiate()
	player.name = str(id)
	player.player_id = id
	player.transform = spawn_point.transform
	players.add_child(player)


func load_level(resource : Resource):
	var node : Level = resource.instantiate()
	node.level_finished_loading.connect(add_host)
	node.name = "Level"

	for player in players.get_children():
		players.remove_child(player)
		player.queue_free()
	remove_child(level)
	if level != null:
		level.queue_free()
	add_child(node)
