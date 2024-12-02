extends RigidBody3D

var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_contacts_reported = 1
	contact_monitor = true
	body_entered.connect(on_hit_body)


func on_hit_body(body: Node):
	if body.name != "1" and body.name != "StapleGun":
		look_at(player.global_position)
		freeze = true


func on_timeout():
	max_contacts_reported = 1
	contact_monitor = true
