extends State

var min_airborne_timer

func enter():
	player_input.speed = player.DIVE_SPEED
	player.animation_tree["parameters/state/transition_request"] = "dive"
	player.apply_dive_velocity()
	player.body_collision(2)
	min_airborne_timer = 0

func exit():
	player.body_collision(0)

func process(delta: float):
	if player_input.get_multiplayer_authority() == multiplayer.get_unique_id():
		player_input.process_directional_input(delta)
		player_input.process_controller_camera(delta)
		player_input.interact(delta)
		player.animate_interaction()
	
	if player._is_on_floor:
		state_machine.state = "idle"
	
	if multiplayer.is_server():
		player.apply_input(delta)

func input(event: InputEvent):
	player_input.process_mouse_camera(event)
