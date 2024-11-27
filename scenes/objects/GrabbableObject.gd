extends RigidBody3D
class_name GrabbableObject

enum TYPE{PROP, TOOL}

@export var type: TYPE
@export var multiplayer_synchronizer : MultiplayerSynchronizer
@export var multiplayer_authority : int :
	set(id):
		set_multiplayer_authority(id, true)
		multiplayer_authority = id

var grab_target: Node3D
var main: Main
var player: Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main = get_node("/root/Main")
	multiplayer_authority = 1
	set_process(false)


@rpc("any_peer", "call_local")
func change_authority(id):
	multiplayer_authority = id


func grabbed(_player: Player):
	player = _player
	change_authority.rpc(player.player_id)
	match type:
		TYPE.PROP:
			grab_target = player.carry_point
		TYPE.TOOL:
			grab_target = player.tool_point
	set_process(true)


func throw(direction: Vector3, strength: float):
	global_position = grab_target.global_position
	linear_velocity = direction * strength
	player = null
	grab_target = null
	change_authority.rpc(1)
	set_process(false)

# should be overwritten by each tool's script that inherits this script
func use():
	pass

func process():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if type == TYPE.TOOL:
		if Input.is_action_just_pressed("use"):
			use.rpc()
	position = grab_target.global_position
	rotation = grab_target.global_rotation
	process()
