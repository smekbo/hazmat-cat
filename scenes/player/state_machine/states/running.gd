extends State


func enter():
	player_input.speed = player.RUN_SPEED
	player.animation_tree["parameters/state/transition_request"] = "run"

func exit():
	pass

func process(delta: float):
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		player_input.process_directional_input(delta)
		player_input.process_controller_camera(delta)
	
		if Input.is_action_just_released("run"):
			state_machine.transition_to("walking")
		if Input.is_action_just_pressed("jump"):
			state_machine.transition_to("jumping")
		if player_input.motion == Vector2.ZERO:
			state_machine.transition_to("idle")	
	
	if multiplayer.is_server():
		player.apply_input(delta)

func input(event: InputEvent):
	player_input.process_mouse_camera(event)
