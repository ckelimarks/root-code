extends SubViewportContainer

# ATTRIBUTES
var fade = 0
var eye_material = false
var red = Color.html("#ff0000")
var aqua = Color.html("#00c4f6")
var transferred = false
var elapsed = 0
var transfer_delay = 3

# NODES
@onready var Screen = $SubViewport/InnerColliders/MatrixScreen

func _ready():
	$SubViewport.own_world_3d = true
	await Mainframe.intro("Console")
	attach_hero()
	Screen.play()

func attach_hero():
	Hero.get_parent().remove_child(Hero)
	$SubViewport.add_child(Hero)
	Hero.global_position = $SubViewport/SpawnCylinder.global_position
	Hero.global_position.z -= 34

func _process(delta):
	SoundManager.march_db_target = (40 - Cam.size) * 0.5
	#elapsed = 3

	if transferred: return
	
	if !eye_material:
		if is_instance_valid(EnemyManager.Platoon.chosen.enemy):
			eye_material = EnemyManager.Platoon.chosen.enemy.Robot.get_node("%LeftEye").get_active_material(0).duplicate()
			EnemyManager.Platoon.chosen.enemy.Robot.get_node("%LeftEye").material_override = eye_material
			EnemyManager.Platoon.chosen.enemy.Robot.get_node("%RightEye").material_override = eye_material

	modulate = Color(1, 1, 1, fade)
	SoundManager.march_db_target += log(1-fade) * 10;
		
	#print("modulate: ", modulate)
	#print("transferred = false")
	#print("fade: ", fade)
	if Hero.action and AudioServer.get_bus_effect_count(SoundManager.BUS_SFX) > 0:
		AudioServer.set_bus_effect_enabled(SoundManager.BUS_SFX, 0, true)
	elif AudioServer.get_bus_effect_count(SoundManager.BUS_SFX) > 0:
		AudioServer.set_bus_effect_enabled(SoundManager.BUS_SFX, 0, false)

	var i = 0.8 + 0.19 * int(Hero.action)
	fade = fade * i + int(Hero.action || Hero.dead) * (1-i)
	var gap = (Hero.global_position - Screen.global_position).length()
	
	#if true:
	#print("gap: ", gap, " action: ", Hero.action, " angle: ", abs(PI/4-PI - Hero.Robot.global_rotation.y))
	if gap<7.1 and Hero.action and abs(PI/4-PI - Hero.Robot.global_rotation.y) < 0.01:
		elapsed += delta #+ 3
		if randf() < glitch_curve(elapsed): # function should cos ramp up and stay at 1
			modulate = Color(1, 1, 1, 0)
			if is_instance_valid(EnemyManager.Platoon.chosen.enemy):
				EnemyManager.Platoon.chosen.enemy.Robot.get_node("%ThirdEye").visible = randf() < elapsed/3
				eye_material.emission = red.lerp(aqua, elapsed-2)
				if elapsed > transfer_delay:
					mind_transfer()

	else:
		elapsed = 0
		if is_instance_valid(EnemyManager.Platoon.chosen.enemy):
			EnemyManager.Platoon.chosen.enemy.Robot.get_node("%ThirdEye").visible = false
			eye_material.emission = red.lerp(aqua, elapsed)
			
			#EnemyManager.Platoon.chosen.Robot.get_node("%LeftEye").get_active_material(0).emission = "#ff0000"
			#EnemyManager.Platoon.chosen.Robot.get_node("%RightEye").get_active_material(0).emission = "#ff0000"
			
		
	Screen.modulate = Color(1, 1, 1, max(0, 1.8 - gap/7))
	var cam_size_target = 30+gap*0.8
	$SubViewport/Camera.size = $SubViewport/Camera.size * 0.99 + cam_size_target * (0.01)

func glitch_curve(x):
	if x < 1: return (1-cos(PI*x))/2
	else: return 1

func mind_transfer():
	Hero.global_position = EnemyManager.Platoon.chosen.enemy.global_position
	EnemyManager.Platoon.chosen.hacked = true
	EnemyManager.Platoon.unspawn(EnemyManager.Platoon.chosen)
	EnemyManager.Platoon.chosen.spawned = true
	Hero.get_parent().remove_child(Hero)
	get_tree().root.add_child(Hero)
	visible = false
	Hero.dead = false
	Hero.awaken()
	#print("transfer")
	transferred = true
