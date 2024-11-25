extends GrabbableObject

@onready var staple_scene = preload("res://scenes/tools/staple_gun/staple.tscn")
@onready var raycast: RayCast3D = $RayCast3D

func ready():
	raycast = player.player_input.interact_ray

@rpc("call_local")
func use():
	if raycast.is_colliding():
		var staple: StaticBody3D = staple_scene.instantiate()
		staple.global_position = raycast.get_collision_point()
		staple.look_at_from_position(raycast.get_collision_point(), global_position)
		main.level.objects.add_child(staple, true)
		

func process():
	#rotation = Vector3(player.player_input.camera_rot.rotation.x, -player.player_input.camera_base.rotation.y, 0)
	look_at(player.camera_look_point.global_position)
