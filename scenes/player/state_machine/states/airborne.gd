extends State

var fall_time: float


func enter():
	fall_time = 0
	player.animation_tree["parameters/state/transition_request"] = "fall"


func process(delta: float):
	if player_input.get_multiplayer_authority() == multiplayer.get_unique_id():
		player_input.process_directional_input(delta)
		player_input.process_controller_camera(delta)
		player_input.interact(delta)
		player.animate_interaction()
	
	if multiplayer.is_server():
		player.apply_input(delta)

	if player._is_on_floor and not player.animation_tree["parameters/land/active"]:
		if fall_time > 1.1:
			state_machine.state = "fall_stun"
		else:
			player.animation_tree["parameters/land/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

	fall_time += delta
	print(fall_time)

func on_land_animation_finished():
	state_machine.state = "idle"


func physics(delta):
	check_for_ledge_grab()


func input(event: InputEvent):
	player_input.process_mouse_camera(event)


# Ledge grab
func check_for_ledge_grab():
	if player.detect_wall_lower.is_colliding():
		var lower_wall_collision_point = player.detect_wall_lower.get_collision_point()
		# get the distance to from the ray origin to the lower collision point
		var dist_to_lower = lower_wall_collision_point.distance_to(player.detect_wall_lower.global_position)
		if player.detect_wall_upper.is_colliding():
			var upper_wall_collision_point = player.detect_wall_upper.get_collision_point()
			# get the distance to from the ray origin to the upper collision point
			var dist_to_upper = upper_wall_collision_point.distance_to(player.detect_wall_upper.global_position)
			# if the upper is further away than the lower, we should have a ledge
			if dist_to_upper - dist_to_lower > 0.01:
				find_ledge(lower_wall_collision_point, upper_wall_collision_point)
		
		# if the upper detector isn't colliding, we should also still have a ledge
		else:
			find_ledge(lower_wall_collision_point)


func find_ledge(lower_point: Vector3, upper_point: Vector3 = Vector3.ZERO):
	if Input.is_action_pressed("jump") or Input.is_action_pressed("move_forward"):
		if upper_point != Vector3.ZERO:
			# move ledge floor detector to be between both points
			player.detect_ledge_floor.global_position = (lower_point + upper_point) / 2
		else:
			# or just move it to where the lower detector collided
			var wall_direction = player.detect_wall_lower.global_position.direction_to(lower_point)
			player.detect_ledge_floor.global_position = lower_point + (wall_direction * 0.1)
		
		player.detect_ledge_floor.global_position.y = player.detect_wall_upper.global_position.y
			
		if player.detect_ledge_floor.is_colliding():
			var ledge_floor_position = player.detect_ledge_floor.get_collision_point()
			
			player.ledge_grab_position = Vector3(lower_point.x, ledge_floor_position.y, lower_point.z)  
			player.ledge_grab_position = player.ledge_grab_position - player.detect_wall_upper.position
				
			state_machine.state = "ledge_grab"
