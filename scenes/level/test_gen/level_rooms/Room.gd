extends Node3D
class_name Room

signal room_loaded

@export var ceiling: Node3D
@export var connectors: Node3D

var room_id

func _ready() -> void:
	ceiling.show()
	room_loaded.emit()
