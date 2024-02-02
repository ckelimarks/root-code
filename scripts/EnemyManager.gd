extends Node3D

var enemy_scene = preload("res://scenes/Enemy.tscn")
var max_enemies = 100
var enemy_spawn_cooldown = 1
var enemy_spawn_heat = 0
var enemies = []

func spawn_enemy():
	var enemy_instance = enemy_scene.instantiate()
	var position = Hero.global_position + Vector3(randf_range(-100, 100), 0, randf_range(-100, 100))

	# Set the enemy's position and add it to the scene
	enemy_instance.global_position = position
	enemy_instance.add_to_group("enemies")
	add_child(enemy_instance)

	# Keep track of the enemy instance
	enemies.append(enemy_instance)
	
	for enemy in enemies:
		pass
		#print(enemy.distance_to_hero)
		

func _process(delta):
	enemy_spawn_heat -= delta
	if enemies.size() < max_enemies && enemy_spawn_heat <= 0:
		enemy_spawn_heat = enemy_spawn_cooldown
		spawn_enemy()
