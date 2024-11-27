extends Node
class_name State

var state_machine: PlayerStateMachine

var player: Player
var player_input: PlayerInput

func _ready() -> void:
	state_machine = $".."
	player = $"../.."
	player_input = $"../../input_synchronizer"
	
	# probably not a huge optimization, but States shouldn't call these anyway
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
