extends SubViewport

# ATTRIBUTES
var fade = 0
var hack = 0
var chosen
var eye_material = false
var red = Color.html("#ff0000")
var aqua = Color.html("#00c4f6")

# NODES
@onready var Screen = $InnerColliders/MatrixScreen

func _ready():
	own_world_3d = true
	await get_tree().create_timer(0).timeout
	Hero.get_parent().remove_child(Hero)
	Hero.global_position = $SpawnCylinder.global_position
	add_child(Hero)
	Screen.play()
	
var elapsed = 0
func _process(delta):
	if !eye_material:
		chosen = EnemyManager.Platoon.chosen.enemy
		if is_instance_valid(chosen):
			eye_material = chosen.Robot.get_node("%LeftEye").get_active_material(0).duplicate()
			chosen.Robot.get_node("%LeftEye").material_override = eye_material
			chosen.Robot.get_node("%RightEye").material_override = eye_material
			chosen.Robot.get_node("%ThirdEye").material_override = eye_material

	get_parent().modulate = Color(1, 1, 1, fade)
	var i = 0.8 + 0.19 * int(Hero.woke)
	fade = fade * i + int(Hero.woke) * (1-i)
	var gap = (Hero.global_position - Screen.global_position).length()
	#print(PI/4-PI - Hero.Robot.global_rotation.y)
	if gap<6.29 and Hero.woke and abs(PI/4-PI - Hero.Robot.global_rotation.y) < 0.01:
		elapsed += delta
		if randf() < (1-cos(elapsed))/2:
			get_parent().modulate = Color(1, 1, 1, 0)
			var chosen = EnemyManager.Platoon.chosen.enemy
			if is_instance_valid(chosen):
				hack += delta
				if elapsed > 6: 
					chosen.Robot.get_node("%ThirdEye").visible = true
				eye_material.emission = red.lerp(aqua, hack)
				

	else:
		elapsed = 0
		hack *= 0.99
		var chosen = EnemyManager.Platoon.chosen.enemy
		if is_instance_valid(chosen):
			chosen.Robot.get_node("%ThirdEye").visible = false
			eye_material.emission = red.lerp(aqua, hack)
			
			#chosen.Robot.get_node("%LeftEye").get_active_material(0).emission = "#ff0000"
			#chosen.Robot.get_node("%RightEye").get_active_material(0).emission = "#ff0000"
			
		
	Screen.modulate = Color(1, 1, 1, max(0, 1.8 - gap/7))
	var cam_size_target = 35+gap*0.7
	$Camera.size = $Camera.size * 0.999 + cam_size_target * (0.001)
