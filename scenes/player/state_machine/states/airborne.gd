extends State


func exit():
	pass

func process(delta: float):
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		player_input.process_directional_input(delta)
		player_input.process_controller_camera(delta)
	
	if multiplayer.is_server():
		player.apply_input(delta)
	
	if player.velocity.y < 0:
		player.animation_tree["parameters/state/transition_request"] = "fall"
	
	if player.is_on_floor():
		state_machine.transition_to("idle")

func input(event: InputEvent):
	player_input.process_mouse_camera(event)
