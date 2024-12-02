extends RigidBody3D
class_name GrabbableObject

@onready var multiplayer_synchronizer : MultiplayerSynchronizer = get_node("MultiplayerSynchronizer")
@onready var outline: MeshInstance3D = get_node("outline")
@onready var players_node: Node = get_node("/root/Main/Players")
@onready var main: Main = get_node("/root/Main")

enum TYPE{PROP, TOOL}
enum CARRY{FRONT, OVERHEAD}

@export var type: TYPE
@export var carry: CARRY

var carry_target: Node3D
var player: Player
@export var held_by_id : int = 0 :
	set(id):
		if id != 0:
			player = players_node.get_node(str(id))
			set_multiplayer_authority(id, true)
		held_by_id = id
var outline_scale: float = 1 :
	set(scale):
		outline.scale = Vector3(scale, scale, scale)
		outline_scale = scale


# Set replication config so that all you should need is to 
#   add the sync node to a new grabbable
func _ready() -> void:
	var config: SceneReplicationConfig = SceneReplicationConfig.new()
	config.add_property(".:position")
	config.add_property(".:rotation")
	config.add_property(".:held_by_id")
	config.property_set_replication_mode(".:held_by_id",SceneReplicationConfig.REPLICATION_MODE_ON_CHANGE)
	multiplayer_synchronizer.replication_config = config
	ready()


@rpc("any_peer")
func object_stolen():
	player.player_input.interaction_state = player.player_input.INTERACTION_STATES.EMPTY
	carry_target = null
	player = null


@rpc("any_peer", "call_local")
func object_grabbed(grabbed_by_id):
	held_by_id = grabbed_by_id	
	for exception in get_collision_exceptions():
		remove_collision_exception_with(exception)
	add_collision_exception_with(player)


@rpc("any_peer", "call_local")
func object_dropped():
	player.player_input.interaction_state = player.player_input.INTERACTION_STATES.EMPTY	
	remove_collision_exception_with(player)
	carry_target = null
	player = null
	held_by_id = 0


func grabbed(grabbed_by_id: int):
	if held_by_id != 0:
		object_stolen.rpc_id(held_by_id)	
	object_grabbed.rpc(grabbed_by_id)
	match carry:
		CARRY.OVERHEAD:
			carry_target = player.overhead_carry_point
		CARRY.FRONT:
			carry_target = player.front_carry_point


func throw(direction: Vector3, strength: float):
	global_position = carry_target.global_position
	linear_velocity = direction * strength
	remove_collision_exception_with(player)
	carry_target = null
	player = null
	held_by_id = 0


func _physics_process(delta: float) -> void:
	if carry_target != null:
		position = carry_target.global_position
		rotation = carry_target.global_rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if type == TYPE.TOOL and held_by_id != 0:
		if Input.is_action_pressed("prepare_tool"):
			prepare()
		if Input.is_action_just_released("prepare_tool"):
			prepare_done()
		if Input.is_action_just_pressed("use_tool"):
			use.rpc()
	process()
	if outline.visible:
		pass
		#outline_scale = global_position.distance_to(player.global_position)

# inherited ready function
func ready():
	pass

# function used by tools for their left click
func use():
	pass

# function used by tools for their right click
func prepare():
	pass

func prepare_done():
	pass

func process():
	pass
