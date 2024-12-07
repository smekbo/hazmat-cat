extends State


func enter(msg = {}):
	player.global_position = player.ledge_grab_position - Vector3(0,2,0)


func process(delta: float):
	if Input.is_action_just_pressed("jump"):
		state_machine.state = "ledge_grab_jump"


func input(event: InputEvent):
	player_input.process_mouse_camera(event)
