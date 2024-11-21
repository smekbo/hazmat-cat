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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer_authority = 1
	set_process(false)


@rpc("any_peer", "call_local")
func change_authority(id):
	multiplayer_authority = id


func grabbed(player: Player):
	change_authority.rpc(player.player_id)
	match type:
		TYPE.PROP:
			grab_target = player.carry_point
		TYPE.TOOL:
			grab_target = player.tool_point
	set_process(true)


func thrown():
	change_authority.rpc(1)
	grab_target = null
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position = grab_target.global_position
