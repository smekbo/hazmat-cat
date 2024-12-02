extends GrabbableObject

@onready var preview_mesh: Node3D = $preview
@onready var ladder_physics: Area3D = $apply_ladder_physics


func ready():
	preview_mesh.hide()


@rpc("any_peer", "call_local")
func use():
	if player.player_input.use_ray.is_colliding():
		preview_mesh.hide()
		var place_point = player.player_input.use_ray.get_collision_point() + (Vector3.UP * 0.2)
		object_dropped.rpc()
		global_position = place_point


func prepare():
	if player.player_input.use_ray.is_colliding():
		preview_mesh.show()
		var preview_point = player.player_input.use_ray.get_collision_point()
		preview_mesh.global_position = preview_point
	else:
		preview_mesh.hide()


func prepare_done():
	preview_mesh.hide()


func _on_apply_ladder_physics_body_entered(body: Player) -> void:
	body.floor_max_angle = deg_to_rad(90)


func _on_apply_ladder_physics_body_exited(body: Player) -> void:
	body.floor_max_angle = deg_to_rad(45)
