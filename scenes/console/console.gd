extends Control

var screen_y : float
var open = false

@onready var console_output : RichTextLabel = $VBoxContainer/RichTextLabel
@onready var console_input : LineEdit = $VBoxContainer/LineEdit

@onready var main: Main = $".."
@onready var lobby: Lobby = $"../Lobby"

var level_path = "res://scenes/level/%s/level.tscn"


func _ready() -> void:
	# set the vertical size for the console
	#   should probably have this update on window resize
	screen_y = get_viewport_rect().size.y
	position.y = -screen_y
	
	multiplayer.peer_connected.connect(Callable(self, "write"))
	multiplayer.peer_disconnected.connect(Callable(self, "write"))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_console"):
		open = not open
		if open:
			console_input.grab_focus()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			console_input.release_focus()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if open and position.y < 0:
		position.y = lerp(position.y, 0.0, 0.5)
	if not open and position.y > -screen_y:
		position.y = lerp(position.y, -screen_y, 0.1)
		
		
func write(text):
	console_output.text += str(text) + "\n"
		

func _on_console_submit(text: String) -> void:
	var command_string := text.split(" ")
	var command := command_string[0]
	var params := command_string.slice(1)
	console_input.text = ""
	write(text)
	
	var output
	match command:
		"peers":
			write(multiplayer.get_peers())
		"host":
			if params.size() > 0:
				output = lobby.host_game(int(params[0]))
			else:
				output = lobby.host_game()
			console_output.text += "hosting on port %s \n" % output
		"join":
			if params.size() > 1:
				output = lobby.join_game(params[0], int(params[1]))
			else:
				output = lobby.join_game()
			console_output.text += "joining %s \n" % output
		"map":
			if not multiplayer.is_server():
				write("only host can change map")
			else:
				main.load_level.rpc(level_path % params[0])
				write(main.load_level(level_path % params[0]))
