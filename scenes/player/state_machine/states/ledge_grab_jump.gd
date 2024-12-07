extends State


func enter(msg = {}):
	player.apply_ledge_jump_velocity()


func process(delta: float):
	if player_input.get_multiplayer_authority() == multiplayer.get_unique_id():
		player_input.process_directional_input(delta)
		player_input.process_controller_camera(delta)
		player_input.interact(delta)
	
	if multiplayer.is_server():
		player.apply_input(delta)

	if player._is_on_floor:
		state_machine.state = "idle"


func input(event: InputEvent):
	player_input.process_mouse_camera(event)
