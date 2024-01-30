extends Node2D

# Get a reference to the camera node
var enemy_scene = preload("res://scenes/Enemy.tscn")
var max_enemies = 10
var enemy_spawn_cooldown = 1
var enemy_spawn_heat = 0
var enemies = []

func _ready():
	z_as_relative = false
	
#func spawn_enemy(view):
func spawn_enemy():
	var enemy_instance = enemy_scene.instance()
#	var vpos = view.position
#	var vsiz = view.size
#	var position = Vector2(0,0)
#	var seg = int(rand_range(0, 4))
#	if seg == 0:
#		position = Vector2(vpos.x + rand_range(-2,-1)*vsiz.x, vpos.y + rand_range(-1, 1)*vsiz.y)
#	elif seg == 1:
#		position = Vector2(vpos.x + rand_range( 1, 2)*vsiz.x, vpos.y + rand_range(-1, 1)*vsiz.y)
#	elif seg == 2:
#		position = Vector2(vpos.x + rand_range(-1, 1)*vsiz.x, vpos.y + rand_range(-2,-1)*vsiz.y)
#	elif seg == 3:
#		position = Vector2(vpos.x + rand_range(-1, 1)*vsiz.x, vpos.y + rand_range( 1, 2)*vsiz.y)
	var translation = Hero.global_translation + Vector3(rand_range(-100, 100), 0, rand_range(-100, 100))

	# Set the enemy's position and add it to the scene
	enemy_instance.global_translation = translation
	enemy_instance.add_to_group("enemies")
	add_child(enemy_instance)

	# Keep track of the enemy instance
	enemies.append(enemy_instance)
	
	for enemy in enemies:
		pass
		#print(enemy.distance_to_hero)
		

func _process(delta):
	# Define the maximum view rectangle considering the camera's position
	#var view_rect = Rect2(Cam.global_position, get_viewport_rect().size)
	enemy_spawn_heat -= delta
	if enemies.size() < max_enemies && enemy_spawn_heat <= 0:
#		spawn_enemy(view_rect)
		spawn_enemy()
		enemy_spawn_heat = enemy_spawn_cooldown
