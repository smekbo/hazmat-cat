extends State


func enter():
	if multiplayer.is_server():
		state_machine.player.jump()
	state_machine.player.animation_tree["parameters/state/transition_request"] = "jump"

func exit():
	pass

func process(delta: float):
	if multiplayer.is_server():
		state_machine.player.apply_input(delta)

	state_machine.transition_to("airborne")

func input(event: InputEvent):
	state_machine.player_input.process_mouse_camera(event)
