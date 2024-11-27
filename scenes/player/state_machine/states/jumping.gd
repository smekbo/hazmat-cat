extends State


func enter():
	if multiplayer.is_server():
		player.jump()
	player.animation_tree["parameters/state/transition_request"] = "jump"

func exit():
	pass

func process(delta: float):
	if multiplayer.is_server():
		player.apply_input(delta)

	state_machine.state = "airborne"

func input(event: InputEvent):
	player_input.process_mouse_camera(event)
