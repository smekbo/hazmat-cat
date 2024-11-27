extends State


func enter():
	state_machine.player_input.speed = state_machine.player.RUN_SPEED
	state_machine.player.animation_tree["parameters/state/transition_request"] = "run"

func exit():
	pass

func process(delta: float):
	state_machine.player_input.process_directional_input(delta)
	state_machine.player_input.process_controller_camera(delta)
	
	if multiplayer.is_server():
		state_machine.player.apply_input(delta)
		
	if Input.is_action_just_released("run"):
		state_machine.transition_to("walking")
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("jumping")
	if state_machine.player_input.motion == Vector2.ZERO:
		state_machine.transition_to("idle")

func input(event: InputEvent):
	state_machine.player_input.process_mouse_camera(event)
