extends State

var jump_timer: float

func enter():
	jump_timer = 0
	if multiplayer.is_server():
		player.apply_jump_velocity()
	player.animation_tree["parameters/jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func process(delta: float):
	if multiplayer.is_server():
		player.apply_input(delta)
		
	# transition out of falling is handled by player 'falling' signal
	#   connected in state machine ready function

func input(event: InputEvent):
	player_input.process_mouse_camera(event)
