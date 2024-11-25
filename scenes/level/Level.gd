extends Node
class_name Level

@export var spawn_points : Node
@export var objects : Node
@export var object_spawner : MultiplayerSpawner

signal level_finished_loading

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Console.level = self
	ready()
	
# ready function for inherited levels to use
func ready():
	level_finished_loading.emit()
