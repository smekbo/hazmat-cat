extends CharacterBody3D
class_name Player

const DIRECTION_INTERPOLATE_SPEED = 1
const MOTION_INTERPOLATE_SPEED = 10
const ROTATION_INTERPOLATE_SPEED = 10

const WALK_SPEED = 200
const RUN_SPEED = 400
const JUMP_SPEED = 6
var airborne := false

var orientation = Transform3D()
var root_motion = Transform3D()
var motion = Vector2()
var jump_motion: Vector3 

@export var _is_on_floor: bool

@onready var initial_position = transform.origin
@onready var player_input: PlayerInput = $input_synchronizer
@onready var animation_tree = $AnimationTree
@onready var player_model = $player_model
@onready var state_machine: PlayerStateMachine = $state_machine

@export var overhead_carry_point: Node3D
@export var front_carry_point: Node3D
@export var camera_look_point: Node3D

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

enum ANIMATIONS {WALK, RUN}
@export var current_animation := ANIMATIONS.WALK

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
	if target.length() > 0.001:
		var q_from = orientation.basis.get_rotation_quaternion()
		var q_to = Transform3D().looking_at(target, Vector3.UP).basis.get_rotation_quaternion()
		# Interpolate current rotation with desired one.
		orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))

		root_motion = Transform3D(animation_tree.get_root_motion_rotation(), animation_tree.get_root_motion_position())

	var h_speed = Vector3(-target.x, 0, -target.z) * player_input.speed * delta
	velocity = Vector3(h_speed.x, velocity.y, h_speed.z)
	velocity += gravity * delta
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()
	_is_on_floor = is_on_floor()

	orientation.origin = Vector3() # Clear accumulated root motion displacement (was applied to speed).
	orientation = orientation.orthonormalized() # Orthonormalize orientation.

	player_model.global_transform.basis = orientation.basis

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
			match player_input.held_object.carry:
				player_input.held_object.CARRY.OVERHEAD:
					animation_tree["parameters/overhead_carry/blend_amount"] = lerp(animation_tree["parameters/overhead_carry/blend_amount"], 1.0, .2)
					player_input.camera_rot.position.x = lerp(player_input.camera_rot.position.x, 1.0, 0.1)
				player_input.held_object.CARRY.FRONT:
					animation_tree["parameters/front_carry/blend_amount"] = lerp(animation_tree["parameters/front_carry/blend_amount"], 1.0, 0.2)
					player_input.camera_rot.position.x = lerp(player_input.camera_rot.position.x, 1.0, 0.1)
		PlayerInput.INTERACTION_STATES.EMPTY:
			animation_tree["parameters/overhead_carry/blend_amount"] = lerp(animation_tree["parameters/overhead_carry/blend_amount"], 0.0, 0.2)
			animation_tree["parameters/front_carry/blend_amount"] = lerp(animation_tree["parameters/front_carry/blend_amount"], 0.0, 0.2)
			player_input.camera_rot.position.x = lerp(player_input.camera_rot.position.x, 0.0, 0.1)


func apply_jump_velocity():
	velocity.y = JUMP_SPEED


func _on_interact_area_body_entered(body: GrabbableObject) -> void:
	body.outline.show()


func _on_interact_area_body_exited(body: GrabbableObject) -> void:
	body.outline.hide()
