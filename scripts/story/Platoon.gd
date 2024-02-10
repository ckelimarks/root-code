extends Node3D

var platoon_exists = false
var platoon_holes = {}
var platoon_occupied = {}
var platoon_rect = Rect2(Vector2(-100, -100), Vector2(200, 200))
var platoon_spacing = Vector2(10, 20)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_platoon(delta):
	platoon_rect.position.y += delta * 8
	var view_bounds = EnemyManager.get_spawn_rect()
	var spawn_buffer = view_bounds.grow(20)
	var unspawn_buffer = spawn_buffer.grow(20)

	if !platoon_exists:
		process_area(spawn_buffer)
		platoon_exists = true

	else:
		process_perimeter(spawn_buffer, true)
		process_perimeter(unspawn_buffer, false)
		
func process_area(rect: Rect2):
	for y in range(rect.position.y, rect.position.y + rect.size.y, platoon_spacing.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x, platoon_spacing.x):
			if Vector2(x, y).snapped(platoon_spacing) == Vector2(0, 0): 
				platoon_occupied[Vector2(x, y)] = Hero
				platoon_holes[Vector2(x, y)] = true
			else:
				check_and_spawn_unspawn(Vector2(x, y), true)

func process_perimeter(rect: Rect2, is_spawn: bool):
	# Top and bottom
	for x in range(rect.position.x, rect.position.x + rect.size.x, platoon_spacing.x):
		check_and_spawn_unspawn(Vector2(x, rect.position.y), is_spawn) # Top edge
		check_and_spawn_unspawn(Vector2(x, rect.position.y + rect.size.y), is_spawn) # Bottom edge

	# Left and right (excluding corners to avoid double processing)
	for y in range(rect.position.y + platoon_spacing.y, rect.position.y + rect.size.y - platoon_spacing.y, platoon_spacing.y):
		check_and_spawn_unspawn(Vector2(rect.position.x, y), is_spawn) # Left edge
		check_and_spawn_unspawn(Vector2(rect.position.x + rect.size.x, y), is_spawn) # Right edge

func check_and_spawn_unspawn(position: Vector2, is_spawn: bool):
	# Adjust position to grid alignment if necessary
	var grid_position = (position - platoon_rect.position).snapped(platoon_spacing)

	# Depending on whether we are spawning or unspawning
	if is_spawn:
		# Check if within spawn area and not already spawned
		if !platoon_occupied.has(grid_position) and !platoon_holes.has(grid_position):
			platoon_spawn(EnemyManager.spawn_enemy("Stan"), grid_position)
	else:
		# Check if outside spawn area and currently spawned
		if platoon_occupied.has(grid_position):
			unspawn_enemy(platoon_occupied[grid_position])
			platoon_occupied.erase(grid_position)

func unspawn_enemy(enemy):
	if (!EnemyManager.enemies.has(enemy)): return
	EnemyManager.enemies.erase(enemy)
	enemy.queue_free()
	
func platoon_spawn(new_enemy, grid_position):
	new_enemy.global_position = Vector3(grid_position.x + platoon_rect.position.x, 0, grid_position.y + platoon_rect.position.y)
	new_enemy.behaviour = "march"
	new_enemy.speed = 8.0
	new_enemy.platoon_grid_position = grid_position
	var animation_tree = new_enemy.robot.get_node("AnimationTree")
	animation_tree.active = true
	animation_tree.set("parameters/Tree/BlendMove/blend_amount", 1.0)
	animation_tree.set("parameters/Tree/WalkSpeed/scale", 8.0 / 12.0)
	#animation_tree.set("parameters/Tree/Walk/time", other guys time)
	platoon_occupied[grid_position] = new_enemy
