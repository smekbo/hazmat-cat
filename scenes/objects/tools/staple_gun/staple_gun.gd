extends GrabbableObject

@onready var staple_scene = preload("res://scenes/objects/tools/staple_gun/staple.tscn")
@onready var staple_spawn: Node3D = $staple_spawn


@rpc("call_local")
func use():
	var staple: RigidBody3D = staple_scene.instantiate()
	var direction = global_position.direction_to(player.camera_look_point.global_position)
	staple.player = player
	staple.linear_velocity = direction * 70
	staple.global_position = staple_spawn.global_position
	main.level.objects.add_child(staple, true)
		

func process():
	if player != null:
		look_at(player.camera_look_point.global_position)
