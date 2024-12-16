extends State


func enter():
	player.ragdoll.physical_bones_start_simulation()


func process(delta: float):
	pass


func physics(delta):
	pass


func input(event: InputEvent):
	player_input.process_mouse_camera(event)
