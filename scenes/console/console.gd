extends Control

var screen_y : float
var open = false

@onready var console_output : RichTextLabel = $VBoxContainer/RichTextLabel
@onready var console_input : LineEdit = $VBoxContainer/LineEdit


func _ready() -> void:
	screen_y = get_viewport_rect().size.y
	position.y = -screen_y
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_console"):
		open = not open
		if open:
			console_input.grab_focus()
		else:
			console_input.release_focus()
			
	if open and position.y < 0:
		position.y = lerp(position.y, 0.0, 0.5)
	if not open and position.y > -screen_y:
		position.y = lerp(position.y, -screen_y, 0.1)
		

func _on_line_edit_text_submitted(new_text: String) -> void:
	console_input.text = ""
	console_output.text += new_text + "\n"
	
	match new_text:
		"host":
			host_game()
		"join":
			join_game()


func host_game():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(7000)
	multiplayer.multiplayer_peer = peer

func join_game():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client($UI/Online/Address.text, int($UI/Online/Port.value))
	multiplayer.multiplayer_peer = peer
