extends Node
class_name Main

@export var default_level: NodePath = "res://scenes/level/test/level.tscn"

@onready var player_scene: PackedScene = load("res://scenes/player/player.tscn")
@onready var players: Node = $Players
@onready var lobby: Lobby = $Lobby

var level : Level


func _ready() -> void:
	load_level(default_level)


func add_host():
	level = $Level
	
	if multiplayer.is_server():
		lobby.add_player(1)
		for peer in multiplayer.get_peers():
			lobby.add_player(peer)


@rpc
func load_level(path: String):
	var level_scene = load(path)
	if level_scene == null:
		return "couldn't find map %s" % path
	var node : Level = level_scene.instantiate()
	node.level_finished_loading.connect(add_host)
	node.name = "Level"

	for player in players.get_children():
		players.remove_child(player)
		player.queue_free()
	if level != null:
		remove_child(level)
		level.queue_free()
	add_child(node)
	return "level loaded %s" % path
