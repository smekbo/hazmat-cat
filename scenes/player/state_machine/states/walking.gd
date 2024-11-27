extends State


func enter():
	player_input.speed = state_machine.player.WALK_SPEED
	player.animation_tree["parameters/state/transition_request"] = "walk"

func exit():
	pass

func process(delta: float):
	if player_input.get_multiplayer_authority() == multiplayer.get_unique_id():
		player_input.process_directional_input(delta)
		player_input.process_controller_camera(delta)
		player_input.interact(delta)
	
		if Input.is_action_pressed("run"):
			state_machine.state = "running"
		if Input.is_action_just_pressed("jump"):
			state_machine.state = "jumping"
		if player_input.motion == Vector2.ZERO:
			state_machine.state = "idle"
	
	if multiplayer.is_server():
		player.apply_input(delta)

func input(event: InputEvent):
	player_input.process_mouse_camera(event)
