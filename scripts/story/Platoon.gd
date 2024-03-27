extends Node3D

var disabled = false
var debug_all = false
var debug_scalar = 1 + 2*int(debug_all)

# ATTRIBUTES
var exists        = false
var members       = []
var guard_spacing = 5*debug_scalar
var spacing       = Vector2(8.0*debug_scalar, 12.0*debug_scalar)
var size          = Vector2i(int(60/spacing.x), int(1000/spacing.y))
var hero_set      = false
var chosen        = {}
var db_target = 0

# SCENES AND NODES
@onready var Ground = EcologyManager.Ground #get_node("/root/Main/Ground")

func _ready():
	await Mainframe.intro("Platoon")

func _process(delta):
	pass

func update(delta):
	if disabled: return
	
	var view_bounds = EnemyManager.get_spawn_rect()
	var spawn_buffer = view_bounds.grow(20)
	var unspawn_buffer = spawn_buffer.grow(20)

	# initialize the platoon on first update
	if !exists:
		exists = true
		randomize()
		init_ranks()

	spawn_check(spawn_buffer, unspawn_buffer, delta)

func spawn_check(spawn_rect: Rect2, unspawn_rect: Rect2, delta):
	# if notice performance hit, then:
	# cycle through array a little (max) at a time
	for member in members:
		update_member(member, delta)
		if debug_all and !member.spawned: spawn(member)
		if debug_all: continue
		if spawn_rect.has_point(member.position) and !member.spawned: spawn(member)
		if !unspawn_rect.has_point(member.position) and member.spawned: unspawn(member)

func unspawn(member):
	if (!EnemyManager.enemies.has(member.enemy)): return
	EnemyManager.enemies.erase(member.enemy)
	member.enemy.queue_free()
	member.enemy = null
	member.spawned = false
	
func spawn(member):
	member.enemy = EnemyManager.spawn_enemy("Stan")
	member.spawned = true
	member.enemy.global_position = EcologyManager.altitude_at(
		Vector3(member.position.x, 0, member.position.y) )
	#member.enemy.global_position = Vector3(member.position.x, 0, member.position.y)
	member.enemy.mass = 10.0
	member.enemy.speed = 8.0
	member.enemy.damage = 0.5
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

func update_member(member, delta):
	if is_instance_valid(member.enemy):
		var gap = (member.enemy.global_position - Hero.global_position).length()
		member.position = Vector2(member.enemy.global_position.x, member.enemy.global_position.z)
		if EnemyManager.rogue_alert_on and member.mode == "guard" and gap < 20.0: #guard distance by hero level?
			member.enemy.behaviour = "attack"
		member.mode = member.enemy.behaviour
	elif member.mode == "march":
		member.position += Vector2(-1, 1).normalized() * 8.0 * delta
	if over_edge(member):
		recycle(member)
		if is_instance_valid(member.enemy):
			member.enemy.global_position = EcologyManager.altitude_at(
				Vector3(member.position.x, 0, member.position.y) )
			#member.enemy.global_position = Vector3(member.position.x, 0, member.position.y)

func over_edge(member):
	var rotated_position = member.position.rotated(PI/4)
	return rotated_position.x < -500
	
func recycle(member):
	var rotated_position = member.position.rotated(PI/4)
	rotated_position.x += 1000
	member.position = rotated_position.rotated(-PI/4)

func clear_ranks():
	for member in members:
		if is_instance_valid(member.enemy):
			EnemyManager.unspawn_enemy(member.enemy)
	members = []
	
func init_ranks():
	var hx = 0 + randi() % size.x
	var hy = 1 + randi() % 3 # max rows Hero can appear in < size.y
	var edge_distance = 1000 * sqrt(2) / 4 # 1000 comes from ground mesh
	
	for rank in range(3):
		# Guard Stans
		for y in range(int(1000/guard_spacing)+1):
			var py = y * guard_spacing / sqrt(2)
			for side in [-1, 1]:
				var px = (size.x/2+2) * spacing.x / sqrt(2)
				members.append({
					#"position": Vector2( edge_distance*1/2 + (px*side - py), -edge_distance*3/2 + (py + px*side) ),
					#"position": Vector2( edge_distance*2/2 + (px*side - py), -edge_distance*2/2 + (py + px*side) ),
					#"position": Vector2( edge_distance*3/2 + (px*side - py), -edge_distance*1/2 + (py + px*side) ),
					"position": Vector2( edge_distance*(1+rank)/2 + (px*side - py), -edge_distance*(3-rank)/2 + (py + px*side) ),
					"rotation": PI/4 + (1+side)*PI/2,
					"mode": "guard",
					"spawned": false,
					"enemy": null
				})
				
		# Marching Stans
		for y in range(size.y+1):
			var py = y * spacing.y / sqrt(2)
			for x in range(size.x):
				var px = (x - size.x/2) * spacing.x / sqrt(2)
				var grid_position = Vector2( edge_distance*(1+rank)/2 + (px-py), -edge_distance*(3-rank)/2 + (py+px) )
				var member = {
					"position": grid_position,
					"mode": "march",
					"spawned": false,
					"enemy": null
				}
				members.append(member)
				if x == hx and y == hy and rank == 1: #middle rank
					chosen = member
					chosen.hacked = false
					#Cam.global_position = Vector3(chosen.position.x, 0, chosen.position.y) + Cam.initial_offset
