extends Node
class_name PlayerStateMachine

signal state_changed(state: State)

@export var player: Player
@export var player_input: PlayerInput

var state_node: State
@export var state: String = "idle" :
	set(name):
		state = name
		transition_to(name)


func _ready() -> void:
	state_node = get_node("idle")
	player.falling.connect(on_player_falling)


func on_player_falling():
	state = "falling"


func transition_to(state_name: String):
	print(state_name)
	state_node.exit()
	state_node = get_node(state_name) # error handle DEEZ NUTS
	state_node.enter()
	state_changed.emit()


func current_state() -> String:
	return state


func _process(delta: float) -> void:
	state_node.process(delta)
func _physics_process(delta: float) -> void:
	state_node.physics(delta)
func _input(event: InputEvent) -> void:
	state_node.input(event)
