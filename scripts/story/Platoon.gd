extends Node3D

var disabled = false

# ATTRIBUTES
var exists   = false
var holes    = {}
var occupied = {}
var members  = []
var spacing  = Vector2(8.0, 12.0)
var size     = Vector2i(10, int(1000/spacing.y))
var hero_set = false
#var rect     = Rect2(-size/2 * spacing, size * spacing)

@onready var Ground = get_node("/root/Main/Ground")

func _ready():
	pass

func _process(delta):
	pass

func update(delta):
	if disabled: return

	var view_bounds = EnemyManager.get_spawn_rect()
	var spawn_buffer = view_bounds.grow(20)
	var unspawn_buffer = spawn_buffer.grow(20)

	# initialize the platoon on first update
	if !exists:
		randomize()
		var hx = 0 + randi() % size.x
		var hy = 1 + randi() % 3 # max rows Hero can appear in < size.y
		exists = true
		var edge_distance = 1000 * sqrt(2) / 4 # 1000 comes from ground mesh

		# Guard Stans
		for y in range(int(1000/5)):
			var py = y * 5 / sqrt(2)
			for side in [-1, 1]:
				var px = (size.x/2+2) * spacing.x / sqrt(2)
				members.append({
					"position": Vector2( edge_distance + (px*side - py), -edge_distance + (py + px*side) ),
					"rotation": PI/4 + (1+side)*PI/2,
					"mode": "guard",
					"spawned": false,
					"enemy": null
				})
				
		# Marching Stans
		for y in range(size.y):
			var py = y * spacing.y / sqrt(2)	
			for x in range(size.x):
				var px = (x - size.x/2) * spacing.x / sqrt(2)
				var grid_position = Vector2( edge_distance+(px-py), -edge_distance+(py+px) )
				if x == hx and y == hy:
					#hero_set = true
					Hero.global_position = Vector3(grid_position.x, 0, grid_position.y)
					#Cam.global_position = Hero.global_position + Cam.initial_offset
				else:
					members.append({
						"position": grid_position,
						"mode": "march",
						"spawned": false,
						"enemy": null
					})
					
		#process_area(spawn_buffer)
		
	else:
		for member in members:
			if is_instance_valid(member.enemy):
				var gap = (member.enemy.global_position - Hero.global_position).length()
				member.position = Vector2(member.enemy.global_position.x, member.enemy.global_position.z)
				if EnemyManager.rogue_alert_on and member.mode == "guard" and gap < 30.0:
					member.enemy.behaviour = "attack"
				member.mode = member.enemy.behaviour
			elif member.mode == "march":
				member.position += Vector2(-1, 1).normalized() * 8.0 * delta

	spawn_check(spawn_buffer, unspawn_buffer)

func spawn_check(spawn_rect: Rect2, unspawn_rect: Rect2):
	# if notice performance hit, then:
	# cycle through array a little (max) at a time
	for member in members:
		if spawn_rect.has_point(member.position) and !member.spawned:
			spawn(member)
		if !unspawn_rect.has_point(member.position) and member.spawned:
			unspawn(member)

func unspawn(member):
	if (!EnemyManager.enemies.has(member.enemy)): return
	EnemyManager.enemies.erase(member.enemy)
	member.enemy.queue_free()
	member.spawned = false
	member.enemy = null
	
func spawn(member):
	member.enemy = EnemyManager.spawn_enemy("Stan")
	member.spawned = true
	member.enemy.global_position = Vector3(member.position.x, 0, member.position.y)
	member.enemy.mass = 10.0
	member.enemy.speed = 8.0
	var animation_tree = member.enemy.Robot.get_node("AnimationTree")
	#var avoidance = member.enemy.Robot.get_node("Avoidance")
	animation_tree.active = true
	if member.mode == "march":
		member.enemy.behaviour = "march"
		animation_tree.set("parameters/Tree/BlendMove/blend_amount", 1.0)
		animation_tree.set("parameters/Tree/WalkSpeed/scale", 8.0 / 12.0)
	elif member.mode == "guard":
		#avoidance.monitorable = false
		#avoidance.monitoring = false
		member.enemy.behaviour = "guard"
		member.enemy.global_rotation.y = member.rotation
		animation_tree.set("parameters/Tree/BlendMove/blend_amount", 0.0)
		#animation_tree.set("parameters/Tree/WalkSpeed/scale", 0.0)
	#animation_tree.set("parameters/Tree/Walk/time", other guys time)
	#occupied[grid_position] = new_enemy
