extends State


func enter():
	player.animation_tree["parameters/state/transition_request"] = "crouch"
	player.body_collision(1)

func exit():
	player.body_collision(0)

func process(delta: float):
	if player_input.get_multiplayer_authority() == multiplayer.get_unique_id():
		player_input.process_directional_input(delta)
		player_input.process_controller_camera(delta)
		player_input.interact(delta)
		player.animate_interaction()
	
		if Input.is_action_just_released("crouch"):
			state_machine.state = "walking"
		if Input.is_action_just_pressed("jump"):
			state_machine.state = "jumping"
	
		if player.is_falling:
			state_machine.state = "falling"
			
	if multiplayer.is_server():
		player.apply_input(delta)

func input(event: InputEvent):
	player_input.process_mouse_camera(event)
