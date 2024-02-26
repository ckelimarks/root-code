extends Node3D

# ATTRIBUTES
var swarm_spawn_cooldown = 30.0
var rogue_spawn_cooldown =  5.0
var swarm_spawn_heat     = swarm_spawn_cooldown
var rogue_spawn_heat     = rogue_spawn_cooldown
var rogue_alert_on       = false
var max_enemies          = 300 # 10x20 stans + 100 dunes
var enemies              = []

# NODES AND SCENES
var Platoon    = preload("res://scenes/story/Platoon.tscn").instantiate()
var EnemyScene = preload("res://scenes/Enemy.tscn")
var RobotTypes = {
	"DuneDrone": preload("res://scenes/robots/DuneDrone.tscn"),
	"YellowBot": preload("res://scenes/robots/YellowBot.tscn"),
	"Stan":      preload("res://scenes/robots/Stan.tscn"),
}

func _process(delta):
	Platoon.update(delta)
	# these updaters should get moved to story/<BEHAVIOUR_TYPE>.gd scripts
	if rogue_alert_on: 
		rogue(delta)
		swarm(delta)

func get_spawn_rect():
	var view_size = Vector2(get_viewport().size)
	var aspect_ratio = view_size.x / view_size.y
	var x = Cam.size/2 * aspect_ratio
	var z = Cam.size/2 / -Cam.rotation.x
	var cam_center = Cam.global_position - Cam.initial_offset
	return Rect2(Vector2(cam_center.x-x, cam_center.z-z), Vector2(x*2, z*2))

func spawn_enemy(enemy_type):
	# Set the enemy's position and add it to the scene
	var enemy_instance = EnemyScene.instantiate()
	enemy_instance.Robot = RobotTypes[enemy_type].instantiate()
	enemy_instance.add_to_group("enemies")
	add_child(enemy_instance)
	enemies.append(enemy_instance)
	return enemy_instance

func unspawn_enemy(enemy):
	if (!EnemyManager.enemies.has(enemy)): return
	EnemyManager.enemies.erase(enemy)
	enemy.queue_free()

func swarm(delta):
	swarm_spawn_heat -= delta
	if enemies.size() < max_enemies && swarm_spawn_heat <= 0:
		swarm_spawn_heat = swarm_spawn_cooldown
		var distance = get_spawn_rect().size.length()/2
		var angle = randf_range(0, 2*PI)
		var swarm_count = randi_range(5, Hero.current_level+5)
		var swarm_id = randf()
		
		for i in swarm_count:
			var new_drone = spawn_enemy("DuneDrone")
			var swarm_angle = 2*PI/swarm_count*i
			var swarm_radius = 2+i
			new_drone.swarm_id = swarm_id
			new_drone.global_position = Hero.global_position
			new_drone.global_position += Vector3(cos(angle), 0, sin(angle)) * distance
			new_drone.global_position += Vector3(cos(swarm_angle), 0, sin(swarm_angle)) * swarm_radius
			new_drone.behaviour = "swarm"
			new_drone.speed = min(Hero.speed * 1.2, 18.0)
			new_drone.HP = 1
		
			var animation_player = new_drone.Robot.get_node("AnimationPlayer")
			animation_player.active = true
			animation_player.play("drone_Armature|drone_fly")
			
func rogue(delta):
	rogue_spawn_cooldown = 5.0 / (1.0+Hero.current_level)
	rogue_spawn_heat -= delta
	if enemies.size() < max_enemies && rogue_spawn_heat <= 0:
		rogue_spawn_heat = rogue_spawn_cooldown
		var distance = get_spawn_rect().size.length()/2
		var angle = randf_range(0, 2*PI)
		var new_drone = spawn_enemy("DuneDrone")
		new_drone.global_position = Hero.global_position
		new_drone.global_position += Vector3(cos(angle), 0, sin(angle)) * distance
		new_drone.behaviour = "attack"
		new_drone.HP = 1
	
		var animation_player = new_drone.Robot.get_node("AnimationPlayer")
		animation_player.active = true
		animation_player.play("drone_Armature|drone_fly")

