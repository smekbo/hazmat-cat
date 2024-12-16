extends CharacterBody3D
class_name Player

signal falling

const DIRECTION_INTERPOLATE_SPEED = 1
const MOTION_INTERPOLATE_SPEED = 10
const ROTATION_INTERPOLATE_SPEED = 10

# MOVEMENT STATS
const WALK_SPEED = 200
const RUN_SPEED = 400
const DIVE_SPEED = 500
const AIR_FRICTION = 300
const JUMP_STRENGTH = 6
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

# MOVEMENT VARIABLES
var orientation = Transform3D()
var root_motion = Transform3D()
var motion = Vector2()
var jump_motion: Vector3 
var air_friction: float

@export var _is_on_floor: bool
@export var is_falling := false

# node refs
@onready var initial_position = transform.origin
@onready var player_input: PlayerInput = $input_synchronizer
@onready var animation_tree = $AnimationTree
@onready var player_model = $player_model
@onready var state_machine: PlayerStateMachine = $state_machine
@onready var ragdoll : PhysicalBoneSimulator3D = $player_model/metarig/Skeleton3D/PhysicalBoneSimulator3D

#body collision
@onready var standing_collision: CollisionShape3D = $standing
@onready var crouching_collision: CollisionShape3D = $crouching
@onready var diving_collision: CollisionShape3D = $diving
enum COLLISION_STATES {STANDING, CROUCHING, DIVING}
var collision_state = COLLISION_STATES.STANDING

# carry points
@export var overhead_carry_point: Node3D
@export var front_carry_point: Node3D
@export var camera_look_point: Node3D

# ledge grab nodes
@export var detect_wall_upper: RayCast3D
@export var detect_wall_lower: RayCast3D
@export var detect_ledge_floor: RayCast3D
@export var ledge_grab_position: Vector3

var player_id : int	: 
	set(value):
		player_id = value
		$input_synchronizer.set_multiplayer_authority(value)


func _ready():
	# Pre-initialize orientation transform.
	orientation = player_model.global_transform
	orientation.origin = Vector3()
	
	if not multiplayer.is_server():
		set_process(false)
	

func apply_input(delta: float):
	motion = motion.lerp(player_input.motion, MOTION_INTERPOLATE_SPEED * delta)
	var camera_basis : Basis = player_input.get_camera_rotation_basis()
	var camera_z := camera_basis.z
	var camera_x := camera_basis.x

	camera_z.y = 0
	camera_z = camera_z.normalized()
	camera_x.y = 0
	camera_x = camera_x.normalized()

	# Convert orientation to quaternions for interpolating rotation.
	var target = camera_x * motion.x + camera_z * motion.y
	# rotate the player model
	if target.length() > 0.001:
		var q_from = orientation.basis.get_rotation_quaternion()
		var q_to = Transform3D().looking_at(target, Vector3.UP).basis.get_rotation_quaternion()
		# Interpolate current rotation with desired one.
		orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))
	
	orientation.origin = Vector3() # Clear accumulated root motion displacement (was applied to speed).
	orientation = orientation.orthonormalized() # Orthonormalize orientation.

	player_model.global_transform.basis = orientation.basis

	# Get jump strength from player input
	if player_input.jump_strength > 0:
		# clear air_friction and velocity.y value if we just jumped
		air_friction = 0
		if velocity.y < 0:
			velocity.y = player_input.jump_strength
		else:
			velocity.y += player_input.jump_strength
		player_input.jump_strength_used.rpc_id(player_id)

	# air friction
	if not _is_on_floor:
		air_friction += AIR_FRICTION * delta
		air_friction = clamp(air_friction, 0, AIR_FRICTION)
	else:
		air_friction = 0
	# horizontal movement
	var h_speed = Vector3(-target.x, 0, -target.z) * (player_input.speed - air_friction) * delta
	
	velocity = Vector3(h_speed.x, velocity.y, h_speed.z)
	velocity += gravity * delta

	# falling / on_floor variables for multiplayer sync
	_is_on_floor = is_on_floor()
	if velocity.y <= 0 and not is_falling:
		is_falling = true
	if is_falling and is_on_floor() or velocity.y >= 0:
		is_falling = false

	set_up_direction(Vector3.UP)
	move_and_slide()

	# If we're below -40, respawn (teleport to the initial position).
	if transform.origin.y < -40:
		transform.origin = initial_position


func animate_movement():
	match player_input.movement_state:
		PlayerInput.MOVEMENT_STATES.IDLE:
			animation_tree["parameters/state/transition_request"] = "idle"
		PlayerInput.MOVEMENT_STATES.WALK:
			animation_tree["parameters/state/transition_request"] = "walk"
		PlayerInput.MOVEMENT_STATES.RUN:
			animation_tree["parameters/state/transition_request"] = "run"
		PlayerInput.MOVEMENT_STATES.JUMP:
			animation_tree["parameters/state/transition_request"] = "jump"


func animate_interaction():
	match player_input.interaction_state:
		PlayerInput.INTERACTION_STATES.CARRYING:
			# set appropriate arm position for object being carried
			animation_tree["parameters/carry_blend/blend_amount"] = lerp(animation_tree["parameters/carry_blend/blend_amount"], 1.0, .2)
			match player_input.held_object.carry:
				player_input.held_object.CARRY.OVERHEAD:
					animation_tree["parameters/carry_pose/blend_position"] = 1
					player_input.camera_rot.position.x = lerp(player_input.camera_rot.position.x, 1.5, 0.1)
				player_input.held_object.CARRY.FRONT:
					animation_tree["parameters/carry_pose/blend_position"] = -1
					player_input.camera_rot.position.x = lerp(player_input.camera_rot.position.x, 1.5, 0.1)
		PlayerInput.INTERACTION_STATES.EMPTY:
			animation_tree["parameters/carry_blend/blend_amount"] = lerp(animation_tree["parameters/carry_blend/blend_amount"], 0.0, 0.2)
			player_input.camera_rot.position.x = lerp(player_input.camera_rot.position.x, 0.0, 0.1)


func apply_ledge_jump_velocity():
	velocity.y = 10

func apply_dive_velocity():
	velocity.y = 6

# changes collision shape for diving and crouching
func body_collision(state: COLLISION_STATES):
	standing_collision.disabled = true
	crouching_collision.disabled = true
	diving_collision.disabled = true
	match state:
		COLLISION_STATES.STANDING:
			standing_collision.disabled = false
		COLLISION_STATES.CROUCHING:
			crouching_collision.disabled = false
		COLLISION_STATES.DIVING:
			diving_collision.disabled = false

# Show object outlines when we're able to interact with them
func _on_interact_area_body_entered(body: GrabbableObject) -> void:
	body.outline.show()
func _on_interact_area_body_exited(body: GrabbableObject) -> void:
	body.outline.hide()
