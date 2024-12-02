extends Node
class_name Main

@export var current_level: NodePath = "res://scenes/level/movement_test/level.tscn"

@onready var player_scene: PackedScene = load("res://scenes/player/player.tscn")
@onready var players: Node = $Players
@onready var lobby: Lobby = $Lobby

var level : Level


func _ready() -> void:
	Console.main = self
	load_level(current_level)


func on_level_finished_loading():
	level = $Level
	level.level_finished_loading.disconnect(on_level_finished_loading)
	
	if multiplayer.is_server():
		if players.get_node("1"):
			lobby.respawn_players()
		else:
			lobby.add_player(1)
			for peer in multiplayer.get_peers():
				lobby.add_player(peer)


@rpc
func load_level(path: String):
	var level_scene = load(path)
	if level_scene == null:
		return "couldn't find map %s" % path
	var node : Level = level_scene.instantiate()
	node.level_finished_loading.connect(on_level_finished_loading)
	node.name = "Level"

	if level != null:
		remove_child(level)
		level.queue_free()
	add_child(node)
	current_level = path
	return "level loaded %s" % path
