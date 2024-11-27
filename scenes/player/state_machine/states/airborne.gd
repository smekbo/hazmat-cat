extends State


func exit():
	pass

func process(delta: float):
	state_machine.player_input.process_directional_input(delta)
	state_machine.player_input.process_controller_camera(delta)
	
	if multiplayer.is_server():
		state_machine.player.apply_input(delta)
	
	if state_machine.player.velocity.y < 0:
		state_machine.player.animation_tree["parameters/state/transition_request"] = "fall"
	
	if state_machine.player.is_on_floor():
		state_machine.transition_to("idle")

func input(event: InputEvent):
	state_machine.player_input.process_mouse_camera(event)
