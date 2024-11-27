extends Node
class_name PlayerStateMachine

signal state_changed(state: State)

@export var player: Player
@export var player_input: PlayerInput

var state: State
@export var state_name: String = "idle" :
	set(name):
		state_name = name
		transition_to(name)

func _ready() -> void:
	state = get_node("idle")


func transition_to(state_name: String):
	print(state_name)
	state.exit()
	state = get_node(state_name) # error handle DEEZ NUTS
	state.enter()
	state_changed.emit()

func current_state() -> String:
	return state.name

func _process(delta: float) -> void:
	state.process(delta)
func _physics_process(delta: float) -> void:
	state.physics(delta)
func _input(event: InputEvent) -> void:
	state.input(event)
