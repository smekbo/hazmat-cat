extends Node
class_name PlayerStateMachine

signal state_changed(state: State)

@export var player: Player
@export var player_input: PlayerInput

var player_ready = false

var state: State
@export var state_name: String = "idle" :
	set(name):
		if not player_ready:
			state_name = name
			transition_to(name)


func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	set_process_input(false)

func on_player_ready():
	player_ready = true
	transition_to("idle")
	set_process(true)
	set_physics_process(true)
	set_process_input(true)

func transition_to(state_name: String):
	print(state_name)
	if state != null:
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
