extends MultiplayerSynchronizer
class_name PlayerInput

const CAMERA_CONTROLLER_ROTATION_SPEED := 3.0
const CAMERA_MOUSE_ROTATION_SPEED := 0.002

const CAMERA_X_ROT_MIN := deg_to_rad(-45)
const CAMERA_X_ROT_MAX := deg_to_rad(45)

@export var motion := Vector2()

@export var camera_base : Node3D
@export var camera_rot : Node3D
@export var camera_camera : Camera3D
@export var interact_ray : RayCast3D

@onready var player: Player = $".."

enum MOVEMENT_STATES {IDLE, WALK, RUN, JUMP, FALL}
enum INTERACTION_STATES {CARRYING, THROWING, EMPTY}
@export var movement_state : MOVEMENT_STATES = MOVEMENT_STATES.WALK
@export var interaction_state : INTERACTION_STATES = INTERACTION_STATES.EMPTY

var held_object: GrabbableObject
@export var throw_strength: float = 0
var MAX_THROW_STRENGTH = 25

@export var speed: float

func _ready() -> void:
	# Only run process and input if it's the actual player
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		camera_camera.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		set_process(false)
		set_process_input(false)


func process_directional_input(delta: float):
	motion = Vector2(
			Input.get_action_strength("move_left") - Input.get_action_strength("move_right"),
			Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))


func interact(delta):
	if Input.is_action_pressed("interact") and held_object != null:
		match interaction_state:
			INTERACTION_STATES.CARRYING:
				throw_strength += delta * MAX_THROW_STRENGTH
				throw_strength = clamp(throw_strength, 0, MAX_THROW_STRENGTH)

	if Input.is_action_just_released("interact"):
		match interaction_state:
			INTERACTION_STATES.CARRYING:
				var throw_direction = player.global_position.direction_to(player.camera_look_point.global_position).normalized()
				held_object.throw(throw_direction, throw_strength)
				throw_strength = 0
				held_object = null
				interaction_state = INTERACTION_STATES.EMPTY
			INTERACTION_STATES.EMPTY:
				if interact_ray.is_colliding():
					held_object = interact_ray.get_collider()
					held_object.grabbed(player)
					interaction_state = INTERACTION_STATES.CARRYING


func process_mouse_camera(event):
	# Make mouse aiming speed resolution-independent
	# (required when using the `canvas_items` stretch mode).
	var scale_factor: float = min(
			(float(get_viewport().size.x) / get_viewport().get_visible_rect().size.x),
			(float(get_viewport().size.y) / get_viewport().get_visible_rect().size.y)
	)
	if event is InputEventMouseMotion:
		var camera_speed_this_frame = CAMERA_MOUSE_ROTATION_SPEED
		rotate_camera(event.relative * camera_speed_this_frame * scale_factor)


func process_controller_camera(delta: float):
	var camera_move = Vector2(
			Input.get_action_strength("view_right") - Input.get_action_strength("view_left"),
			Input.get_action_strength("view_up") - Input.get_action_strength("view_down"))
	var camera_speed_this_frame = delta * CAMERA_CONTROLLER_ROTATION_SPEED
	if camera_move > Vector2.ZERO:
		rotate_camera(camera_move * camera_speed_this_frame)


func rotate_camera(move):
	camera_base.rotate_y(-move.x)
	# After relative transforms, camera needs to be renormalized.
	camera_base.orthonormalize()
	camera_rot.rotation.x = clamp(camera_rot.rotation.x - move.y, CAMERA_X_ROT_MIN, CAMERA_X_ROT_MAX)


func get_camera_base_quaternion() -> Quaternion:
	return camera_base.global_transform.basis.get_rotation_quaternion()


func get_camera_rotation_basis() -> Basis:
	return camera_rot.global_transform.basis


func update_debug():
	var debug = "throw_strength %s" % throw_strength

	$"../ui/debug".text = debug
