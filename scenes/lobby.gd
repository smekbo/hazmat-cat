extends MultiplayerSpawner
class_name Lobby

@onready var main: Main = $".."
@onready var players: Node = $"../Players"

var peer : MultiplayerPeer = OfflineMultiplayerPeer.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#host_game()
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

func host_game(port: int = 7000):
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	return port

func join_game(address: String = "127.0.0.1", port: int = 7000):
	multiplayer.peer_connected.disconnect(add_player)
	del_player(1)
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	multiplayer.multiplayer_peer = peer
	return "%s:%s" % [address, port]

func add_player(id: int):
	var spawn_point = main.level.spawn_points.get_child(randi() % main.level.spawn_points.get_child_count())
	var player = main.player_scene.instantiate()
	player.name = str(id)
	player.player_id = id
	player.transform = spawn_point.global_transform
	players.add_child(player)

func del_player(id: int):
	if not players.has_node(str(id)):
		return
	players.get_node(str(id)).queue_free()
