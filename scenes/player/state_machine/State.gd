extends Node
class_name State

@export var state_machine: PlayerStateMachine

func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

func enter():
	pass
func exit():
	pass
func input(event):
	pass
func process(_delta: float):
	pass
func physics(_delta: float):
	pass
