extends Camera3D

var ground_material  # RefCounted to the ground material
var position_smoothing_speed = 5.0
var initial_offset: Vector3

func _ready():
	initial_offset = global_position
	pass
	
func _process(delta):
	var target_position = Hero.global_position + initial_offset
	global_position = global_position.lerp(target_position, position_smoothing_speed * delta)
