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

enum MOVEMENT_STATES {WALK, RUN, JUMP, FALL}
enum INTERACTION_STATES {CARRYING, THROWING, EMPTY}
@export var movement_state : MOVEMENT_STATES = MOVEMENT_STATES.WALK
@export var interaction_state : INTERACTION_STATES = INTERACTION_STATES.EMPTY

var held_object: GrabbableObject
var throw_strength: float = 0

func _ready() -> void:
	# Only run process and input if it's the actual player
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		camera_camera.make_current()
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		set_process(false)
		set_process_input(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	motion = Vector2(
			Input.get_action_strength("move_left") - Input.get_action_strength("move_right"),
			Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
	var camera_move = Vector2(
			Input.get_action_strength("view_right") - Input.get_action_strength("view_left"),
			Input.get_action_strength("view_up") - Input.get_action_strength("view_down"))
	var camera_speed_this_frame = delta * CAMERA_CONTROLLER_ROTATION_SPEED
	rotate_camera(camera_move * camera_speed_this_frame)
	
	if Input.is_action_pressed("run"):
		movement_state = MOVEMENT_STATES.RUN
	else:
		movement_state = MOVEMENT_STATES.WALK

	if player.airborne:
		if player.is_on_floor():
			movement_state = MOVEMENT_STATES.WALK
	if Input.is_action_just_pressed("jump"):
		movement_state = MOVEMENT_STATES.JUMP

	if Input.is_action_just_pressed("interact"):
		match interaction_state:
			INTERACTION_STATES.CARRYING:
				if Input.is_action_pressed("interact"):
					throw_strength += delta
				else:
					var throw_direction = player.global_position.direction_to(player.camera_look_point).normalized()
					held_object.throw(throw_direction, throw_strength)
					held_object = null
					interaction_state = INTERACTION_STATES.EMPTY
			INTERACTION_STATES.EMPTY:
				if interact_ray.is_colliding():
					held_object = interact_ray.get_collider()
					held_object.grabbed(player)
					interaction_state = INTERACTION_STATES.CARRYING


func _input(event):
	# Make mouse aiming speed resolution-independent
	# (required when using the `canvas_items` stretch mode).
	var scale_factor: float = min(
			(float(get_viewport().size.x) / get_viewport().get_visible_rect().size.x),
			(float(get_viewport().size.y) / get_viewport().get_visible_rect().size.y)
	)

	if event is InputEventMouseMotion:
		var camera_speed_this_frame = CAMERA_MOUSE_ROTATION_SPEED

		rotate_camera(event.relative * camera_speed_this_frame * scale_factor)


func rotate_camera(move):
	camera_base.rotate_y(-move.x)
	# After relative transforms, camera needs to be renormalized.
	camera_base.orthonormalize()
	camera_rot.rotation.x = clamp(camera_rot.rotation.x - move.y, CAMERA_X_ROT_MIN, CAMERA_X_ROT_MAX)


func get_camera_base_quaternion() -> Quaternion:
	return camera_base.global_transform.basis.get_rotation_quaternion()


func get_camera_rotation_basis() -> Basis:
	return camera_rot.global_transform.basis
