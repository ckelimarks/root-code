extends Node3D

# ATTRIBUTES
var enemy_spawn_cooldown = 1
var enemy_spawn_heat = 0
var rogue_alert_on = false
var max_enemies = 500 # 20x20 stans, 100 dunes
var enemies = []

# NODES AND SCENES
var Platoon    = preload("res://scenes/story/Platoon.tscn").instantiate()
var EnemyScene = preload("res://scenes/Enemy.tscn")
var RobotTypes = {
	"DuneDrone": preload("res://scenes/robots/DuneDrone.tscn"),
	"YellowBot": preload("res://scenes/robots/YellowBot.tscn"),
	"Stan":      preload("res://scenes/robots/Stan.tscn"),
}

func _process(delta):
	Platoon.update_platoon(delta)
	if rogue_alert_on: rogue_alert(delta)

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

func rogue_alert(delta):
	enemy_spawn_heat -= delta
	if enemies.size() < max_enemies && enemy_spawn_heat <= 0:
		enemy_spawn_heat = enemy_spawn_cooldown
		var distance = 50 # hypot(spawn_rect)
		var angle = randf_range(0, 2*PI)
		
		var new_enemy = spawn_enemy("DuneDrone")
		new_enemy.global_position = Hero.global_position + Vector3(cos(angle), 0, sin(angle)) * distance
		new_enemy.behaviour = "attack"
		
		var animation_player = new_enemy.Robot.get_node("AnimationPlayer")
		animation_player.active = true
		animation_player.play("drone_Armature|drone_fly")

