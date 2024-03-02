extends Camera3D

# ATTRIBUTES
var position_smoothing_speed = 0.0
var initial_offset: Vector3
var target_position: Vector3
var debug_cam = !true

func _ready():	
	size = 100
	if debug_cam:
		current = false
		get_node("/root/Main/DebugCam").current = true
		get_node("/root/Main/DebugCam").size = 800
		
	initial_offset = global_position
	
func _process(delta):
	#if Hero.woke:
		#current = false
		#get_node("/root/Main/UndergroundConsole/SubViewport/Camera3D").current = true
		#get_node("/root/Main/UndergroundConsole").visible = true
	#else:
		#current = true
		#get_node("/root/Main/UndergroundConsole/SubViewport/Camera3D").current = false
		#get_node("/root/Main/UndergroundConsole").visible = false

	size = size*0.99 + 40*0.01
	if position_smoothing_speed < 5: position_smoothing_speed += delta * 0.2
	
	if !true:
		target_position = Hero.global_position
	else:
		var chosen = EnemyManager.Platoon.chosen.position
		target_position = Vector3(chosen.x, 0, chosen.y)

	global_position = global_position.lerp(
		target_position + initial_offset,
		position_smoothing_speed * delta
	)
