extends State


func enter():
	player.animation_tree["parameters/state/transition_request"] = "fall"


func process(delta: float):
	if player_input.get_multiplayer_authority() == multiplayer.get_unique_id():
		player_input.process_directional_input(delta)
		player_input.process_controller_camera(delta)
		player_input.interact(delta)
	
	if multiplayer.is_server():
		player.apply_input(delta)

	check_for_ledge_grab()

	if player._is_on_floor:
		player.animation_tree["parameters/land/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		state_machine.state = "idle"


func input(event: InputEvent):
	player_input.process_mouse_camera(event)


# Ledge grab
func check_for_ledge_grab():
	if player.wall_detector.is_colliding():
		if player.open_ledge_detector.get_overlapping_bodies().size() == 0:
			if Input.is_action_pressed("move_forward"):
				var ledge_floor_position = player.ledge_floor_detector.get_collision_point()
				var wall_position = player.wall_detector.get_collision_point()
				
				player.ledge_grab_position = Vector3(wall_position.x, ledge_floor_position.y, wall_position.z)
				player.ledge_floor_position = ledge_floor_position
				state_machine.state = "ledge_grab"
