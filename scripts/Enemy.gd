extends CharacterBody3D

var speed = 10.0  # Adjust as needed
var pushing_strength = 5.0
var HP = 10 # hit points
var damage = 1
var knock_back = 1
var enemy_color = Color(.9, .8, 1, 1)
var is_dead = false
var momentum = Vector3.ZERO
var behaviour = "attack" # assist, march ... etc
#var distance_to_hero = -1

@onready var robot: CharacterBody3D #           = $YellowBot
@onready var robot_animation: AnimationPlayer # = $YellowBot/utilityBot/AnimationPlayer
@onready var killsound       = $AudioStreamPlayer2D
@onready var explosion       = $ExplosionSprite

@onready var blue_orb        = WeaponManager.BlueOrbEmitter
@onready var weapons         = WeaponManager.weapons

func _ready():
	#sprite_node.connect("animation_finished", Callable(self, "_on_animation_finished"))
	#sprite_node.speed_scale = speed / 300.0
	#animation_player.speed_scale = speed / 10.0
	add_child(robot)
	var robot_collider = robot.get_node("Collider")
	$Collider.set_shape(robot_collider.shape)
	$Collider.position = robot_collider.position
	$Collider.rotation = robot_collider.rotation
	SoundManager.MarchSound.pitch_scale = .7
	SoundManager.MarchSound.play()
	#robot_animation.play("Take 001")
	#modulate = enemy_color
	#$CollisionShape3D.radius = stan.collisionshape.radius
	#etc

func _physics_process(delta):
	if is_dead:
		return
		
	global_position.y = 1
	
	#distance_to_hero = global_position.distance_to(Hero.global_position)
	var gap_vector = Hero.global_position - global_position
	var direction: Vector3
	if behaviour == "attack":
		direction = (gap_vector).normalized()
		SoundManager.MarchSound.stop()
	elif behaviour == "march":
		direction = Vector3(0, 0, 1)
		
	
	global_rotation.y = atan2(-direction.z, direction.x) + PI / 2
	var start_position = global_position
	
	if HP > 0:
		
		var real_gap_vector = gap_vector #* unISO #de-isometricify before using the angle
		var angle = atan2(real_gap_vector.y, real_gap_vector.x)
		var angle_dir = int(angle / (PI / 4)) % 8
#		sprite_node.play("walk_"+["e","se","s","sw","w","nw","n","ne"][angle_dir])
	
	# First, try to move normally.	
	var push_vector = Vector3.ZERO
	var collision = move_and_collide(direction * speed * delta)
	momentum *= Vector3(.95, .95, .95)

	if collision:
		var collider = collision.get_collider()
		
		if collider == Hero or weapons.has(collider): 
			behaviour = "attack"
			speed = 10
			EnemyManager.rogue_alert_on = true
		
		if weapons.has(collider):
			behaviour = "attack"
			SoundManager.EnemyStrike.play()
			SoundManager.EnemyStrike.volume_db = -40 + collider.power * 3
			HP -= collider.damage
			momentum += (global_position - Hero.global_position).normalized() * sqrt(collider.knock_back / 2)
			glow()
			if HP <= 0:
				is_dead = true
				speed = 0
				killsound.play()
				
				#enemy_node.play("dead")
				# remove from collision layers
				set_collision_layer_value(0, false)
				set_collision_mask_value(0, false)
				set_collision_layer_value(1, false)
				set_collision_mask_value(1, false)
				EnemyManager.enemies.erase(self)
				dead()
			
		# Attempt to push the collider by manually adjusting the enemy's global_position
		push_vector = collision.get_remainder().normalized() * pushing_strength * delta
	
	global_position += push_vector + momentum

var exp_gem_scene = preload("res://scenes/ExpGem.tscn")

func glow():
	pass
	#glow_sprite.visible = true
	#modulate = Color(1, 0, 0, 1)
	#await get_tree().create_timer(0.2).timeout
	#modulate = enemy_color
	#glow_sprite.visible = false
	
func dead():
	#if sprite_node.get_animation() == "dead":
	var gem_instance = exp_gem_scene.instantiate()
	gem_instance.global_position = global_position
	EnemyManager.add_child(gem_instance)
	EnemyManager.enemies.erase(self)
	explosion.visible = true
	robot.visible = false
	$Collider.disabled = true
	explosion.rotation = Vector3(-35,0,0) - global_rotation
	explosion.play("explosion")
	await get_tree().create_timer(2).timeout	
	self.queue_free()
	
func _on_collision(body):
	print("Collision with:", body.name)
	print("Collider type:", body.get_type())
