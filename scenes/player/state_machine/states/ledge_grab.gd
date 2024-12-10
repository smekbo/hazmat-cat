extends State


func enter(msg = {}):
	player.animation_tree["parameters/ledge_grab/blend_amount"] = 1


func exit():
	player.animation_tree["parameters/ledge_grab/blend_amount"] = 0


func process(delta: float):
	if multiplayer.is_server():
		player.global_position = lerp(player.global_position, player.ledge_grab_position, 0.5)
	
	if Input.is_action_just_pressed("jump"):
		state_machine.state = "ledge_grab_jump"


func input(event: InputEvent):
	player_input.process_mouse_camera(event)
