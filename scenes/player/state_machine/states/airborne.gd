extends State


func enter():
	player.animation_tree["parameters/state/transition_request"] = "fall"


func process(delta: float):
	if player_input.get_multiplayer_authority() == multiplayer.get_unique_id():
		player_input.process_directional_input(delta)
		player_input.process_controller_camera(delta)
		player_input.interact(delta)
		player.animate_interaction()
	
	if multiplayer.is_server():
		player.apply_input(delta)

	if player._is_on_floor:
		player.animation_tree["parameters/land/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		state_machine.state = "idle"


func physics(delta):
	player.check_for_ledge_grab()


func input(event: InputEvent):
	player_input.process_mouse_camera(event)
