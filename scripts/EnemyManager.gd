extends Node3D

var enemy_scene = preload("res://scenes/Enemy.tscn")
var robot_types = {
	"DuneDrone": preload("res://scenes/robots/DuneDrone.tscn"),
	"YellowBot": preload("res://scenes/robots/YellowBot.tscn"),
	"Stan":      preload("res://scenes/robots/Stan.tscn"),
}
var max_enemies = 100
var enemy_spawn_cooldown = 1
var enemy_spawn_heat = 0
var enemies = []

func spawn_enemy(enemy_type):
	var distance = 50 #randf_range(50, 60)
	var angle = randf_range(0, 2*PI)
	var position = Hero.global_position + Vector3(cos(angle), 0, sin(angle)) * distance

	# Set the enemy's position and add it to the scene
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.robot = robot_types[enemy_type].instantiate()
	enemy_instance.global_position = position
	enemy_instance.add_to_group("enemies")
	add_child(enemy_instance)
	enemies.append(enemy_instance)
	
func _process(delta):
	#rogueAlert(delta)
	pass
	
func rogueAlert(delta):
	enemy_spawn_heat -= delta
	if enemies.size() < max_enemies && enemy_spawn_heat <= 0:
		enemy_spawn_heat = enemy_spawn_cooldown
		spawn_enemy("DuneDrone")
