extends Camera3D

# ATTRIBUTES
var position_smoothing_speed = 0.0
var initial_offset: Vector3
var target_position: Vector3
var debug_cam = false

func _ready():	
	size = 100
	if debug_cam:
		current = false
		get_node("/root/Main/DebugCam").current = true
		get_node("/root/Main/DebugCam").size = 800
		
	initial_offset = global_position
	
func _process(delta):
	size = size*0.99 + 40*0.01
	if position_smoothing_speed < 5: position_smoothing_speed += delta * 0.2
	
	if Hero.woke:
		target_position = Hero.global_position
	else:
		var chosen = EnemyManager.Platoon.chosen.position
		target_position = Vector3(chosen.x, 0, chosen.y)

	global_position = global_position.lerp(
		target_position + initial_offset,
		position_smoothing_speed * delta
	)
