extends Node3D

var enemy_scene = preload("res://scenes/Enemy.tscn")
var robot_types = {
	"DuneDrone": preload("res://scenes/robots/DuneDrone.tscn"),
	"YellowBot": preload("res://scenes/robots/YellowBot.tscn"),
	"Stan":      preload("res://scenes/robots/Stan.tscn"),
}
var max_enemies = 500 # 20x20 stans, 100 dunes
var enemy_spawn_cooldown = 1
var enemy_spawn_heat = 0
var enemies = []
var rogue_alert_on = false
var platoon_exists = false

func spawn_enemy(enemy_type):
	# Set the enemy's position and add it to the scene
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.robot = robot_types[enemy_type].instantiate()
	enemy_instance.add_to_group("enemies")
	add_child(enemy_instance)
	enemies.append(enemy_instance)
	return enemy_instance
	
func _process(delta):
	platoon(delta)
	if rogue_alert_on: rogue_alert(delta)
	
func platoon(delta):
	#this should spawn / unspawn as they go on off screen
	if !platoon_exists:
		for x in range(-10, 10):
			for z in range(-10, 10):
				if x == 0 && z == 0: continue
				var new_enemy = spawn_enemy("Stan")
				new_enemy.global_position = Vector3(x, 0, z) * 10
				new_enemy.behaviour = "march"
				new_enemy.speed = 8.0
				var animation_tree = new_enemy.robot.get_node("AnimationTree")
				animation_tree.active = true
				animation_tree.set("parameters/Tree/BlendMove/blend_amount", 1.0)
				animation_tree.set("parameters/Tree/WalkSpeed/scale", 8.0 / 12.0)
				
		platoon_exists = true

func rogue_alert(delta):
	enemy_spawn_heat -= delta
	if enemies.size() < max_enemies && enemy_spawn_heat <= 0:
		enemy_spawn_heat = enemy_spawn_cooldown
		var new_enemy = spawn_enemy("DuneDrone")
		var distance = 50 #randf_range(50, 60)
		var angle = randf_range(0, 2*PI)
		new_enemy.global_position = Hero.global_position + Vector3(cos(angle), 0, sin(angle)) * distance
		new_enemy.behaviour = "attack"
		var animation_player = new_enemy.robot.get_node("AnimationPlayer")
		animation_player.active = true
		animation_player.play("drone_Armature|drone_fly")

