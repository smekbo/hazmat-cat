extends State

var grab_timer: float

func enter(msg = {}):
	player.global_position = player.ledge_grab_position - Vector3(0,2,0)
	grab_timer = 0

func process(delta: float):
	if grab_timer > 1:
		player.global_position = player.ledge_floor_position
		state_machine.state = "idle"
	grab_timer += delta

func input(event: InputEvent):
	player_input.process_mouse_camera(event)
