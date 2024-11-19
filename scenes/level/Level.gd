extends Node
class_name Level

@export var spawn_points : Node

signal level_finished_loading

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_finished_loading.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass