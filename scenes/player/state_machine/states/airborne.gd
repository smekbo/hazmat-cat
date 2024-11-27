extends State

var min_airborne_time
var min_airbone_timer

func enter():
	min_airborne_time = 0.25
	min_airbone_timer = 0

func exit():
	pass

func process(delta: float):
	if player_input.get_multiplayer_authority() == multiplayer.get_unique_id():
		player_input.process_directional_input(delta)
		player_input.process_controller_camera(delta)
		player_input.interact(delta)
	
		if min_airbone_timer > min_airborne_time and player._is_on_floor:
			state_machine.state = "idle"
		min_airbone_timer += delta
	
	if multiplayer.is_server():
		player.apply_input(delta)
	
	if player.velocity.y < 0:
		player.animation_tree["parameters/state/transition_request"] = "fall"

func input(event: InputEvent):
	player_input.process_mouse_camera(event)
