extends State

func enter():
	player_input.speed = 100
	player.animation_tree["parameters/state/transition_request"] = "idle"

func process(delta: float):
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		player_input.process_directional_input(delta)
		player_input.process_controller_camera(delta)
	
		if Input.is_action_just_pressed("jump"):
			state_machine.state = "jumping"
		if player_input.motion != Vector2.ZERO:
			state_machine.state = "walking"
	
	if multiplayer.is_server():
		player.apply_input(delta)	

func input(event: InputEvent):
	player_input.process_mouse_camera(event)