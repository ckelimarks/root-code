extends Camera3D

# ATTRIBUTES
var position_smoothing_speed = 5.0
var initial_offset: Vector3
var debug_cam = !true

func _ready():
	if debug_cam:
		current = false
		get_node("/root/Main/DebugCam").current = true
		get_node("/root/Main/DebugCam").size = 700
		
	initial_offset = global_position
	
func _process(delta):
	var target_position = Hero.global_position + initial_offset
	global_position = global_position.lerp(
		target_position, 
		position_smoothing_speed * delta
	)
