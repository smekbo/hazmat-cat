extends Marker3D
class_name Connector

signal connector_loaded

var open = true
var loaded = false

func _ready() -> void:
    connector_loaded.emit()
