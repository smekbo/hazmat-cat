extends State

@onready var jump_timer: Timer = $Timer

func enter():
	jump_timer.start()
	player_input.jump_strength = player.JUMP_STRENGTH
	player.animation_tree["parameters/jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	print(player.velocity.y)

func process(delta: float):
	if Input.is_action_pressed("jump") and not jump_timer.is_stopped():
		player_input.jump_strength += pow(player.JUMP_STRENGTH, 1.1) * delta
	if player_input.get_multiplayer_authority() == multiplayer.get_unique_id():
		player_input.process_directional_input(delta)
		player_input.process_controller_camera(delta)
		player_input.interact(delta)
		player.animate_interaction()

	if multiplayer.is_server():
		player.apply_input(delta)

	if player.is_falling:
		state_machine.state = "falling"


func input(event: InputEvent):
	player_input.process_mouse_camera(event)
