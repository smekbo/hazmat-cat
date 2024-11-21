extends Node
class_name Level

@export var spawn_points : Node

signal level_finished_loading

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ready()
	level_finished_loading.emit()
	
# ready function for inherited levels to use
func ready():
	pass
