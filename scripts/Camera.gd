extends Camera

var ground_material  # Reference to the ground material
var smoothing_speed = 5.0

func _ready():
	pass
	
func _process(delta):
	var target_position = Hero.global_translation + Vector3(100, 100, 100)
	global_translation = global_translation.linear_interpolate(target_position, smoothing_speed * delta)
