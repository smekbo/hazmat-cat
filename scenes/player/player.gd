extends CharacterBody3D
class_name Player

const DIRECTION_INTERPOLATE_SPEED = 1
const MOTION_INTERPOLATE_SPEED = 10
const ROTATION_INTERPOLATE_SPEED = 10

var orientation = Transform3D()
var root_motion = Transform3D()
var motion = Vector2()

@onready var initial_position = transform.origin
@onready var player_input = $input_synchronizer
@onready var animation_tree = $AnimationTree
@onready var player_model = $player_model

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


func _physics_process(delta: float):
	if multiplayer.is_server():
		apply_input(delta)
	else:
		animate(player_input.current_animation, delta)


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

	# Apply root motion to orientation.
	orientation *= root_motion

	var h_velocity = orientation.origin / delta
	velocity.x = h_velocity.x
	velocity.z = h_velocity.z
	velocity += gravity * delta
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()

	orientation.origin = Vector3() # Clear accumulated root motion displacement (was applied to speed).
	orientation = orientation.orthonormalized() # Orthonormalize orientation.

	player_model.global_transform.basis = orientation.basis

	# If we're below -40, respawn (teleport to the initial position).
	if transform.origin.y < -40:
		transform.origin = initial_position

	animate(player_input.current_animation, delta)


func animate(anim: ANIMATIONS, _delta:=0.0):
	match anim:
		ANIMATIONS.WALK:
			# Change state to walk.
			animation_tree["parameters/state/transition_request"] = "walk"
			# Blend position for walk speed based checked motion.
			animation_tree["parameters/walk/blend_position"] = Vector2(motion.length(), 0)
		ANIMATIONS.RUN:
			animation_tree["parameters/state/transition_request"] = "run"
			animation_tree["parameters/run/blend_position"] = Vector2(motion.length(), 0)
