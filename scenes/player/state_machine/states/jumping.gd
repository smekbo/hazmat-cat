extends State

var jump_timer: float

func enter():
	jump_timer = 0
	if multiplayer.is_server():
		player.apply_jump_velocity()
	player.animation_tree["parameters/jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func process(delta: float):
	if player_input.get_multiplayer_authority() == multiplayer.get_unique_id():
		player_input.process_directional_input(delta)
		player_input.process_controller_camera(delta)
		player_input.interact(delta)
		player.animate_interaction()
	
	if player.is_falling:
		state_machine.state = "falling"

	if multiplayer.is_server():
		player.apply_input(delta)
		
	# transition out of falling is handled by player 'falling' signal
	#   connected in state machine ready function

func input(event: InputEvent):
	player_input.process_mouse_camera(event)
