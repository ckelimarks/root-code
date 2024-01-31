extends Camera3D

var ground_material  # RefCounted to the ground material
var position_smoothing_speed = 5.0

func _ready():
	pass
	
func _process(delta):
	var target_position = Hero.global_position + Vector3(100, 100, 100)
	global_position = global_position.lerp(target_position, position_smoothing_speed * delta)
