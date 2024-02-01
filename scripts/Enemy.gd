extends CharacterBody3D

var speed = 15.0  # Adjust as needed
var pushing_strength = 5.0
var HP = 3 # hit points
var power = 1
var enemy_color = Color(.9, .8, 1, 1)

#var distance_to_hero = -1

var sprite_offset = Vector3()

@onready var blue_orb = WeaponManager.BlueOrbEmitter
@onready var smooth_node = $PositionSmoother
@onready var sprite_node = $PositionSmoother/Stan
@onready var enemy_node = $PositionSmoother/YellowBot/utilityBot/AnimationPlayer
@onready var killsound = $AudioStreamPlayer2D
@onready var weapons = WeaponManager.weapons

func _ready():
	#sprite_node.connect("animation_finished", Callable(self, "_on_animation_finished"))
	#sprite_node.speed_scale = speed / 300.0
	sprite_offset = smooth_node.position
	enemy_node.play("Take 001")
	
	#modulate = enemy_color
	#$CollisionShape3D.radius = stan.collisionshape.radius
	#etc


func _physics_process(delta):
	#distance_to_hero = global_position.distance_to(Hero.global_position)
	var gap_vector = Hero.global_position - global_position
	var direction = (gap_vector).normalized()
	global_rotation.y = atan2(-direction.z, direction.x) + PI / 2
	var start_position = global_position
	var sprite_start_position = smooth_node.position  # Save the current position before moving
	
	if HP > 0:
		var real_gap_vector = gap_vector #* unISO #de-isometricify before using the angle
		var angle = atan2(real_gap_vector.y, real_gap_vector.x)
		var angle_dir = int(angle / (PI / 4)) % 8
#		sprite_node.play("walk_"+["e","se","s","sw","w","nw","n","ne"][angle_dir])
	
	# First, try to move normally.	
	var push_vector = Vector3.ZERO
	var recoil = Vector3.ZERO
	var collision = move_and_collide(direction * speed * delta)

	if collision:
		var collider = collision.get_collider()
		
		if weapons.has(collider):
			HP -= collider.power
			recoil = (Hero.global_position - global_position).normalized() * 100
			glow()
			if HP <= 0:
				
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
	
	var new_position = global_position + push_vector - recoil
	var smoothed_position = (start_position + sprite_start_position).lerp(new_position + sprite_offset, 0.3)
	global_position = global_position + (new_position - global_position) #* ISO 
	smooth_node.position = smoothed_position - new_position	
		
	#self.z_index = int(smoothed_position.y - Cam.global_translation.y)

var exp_gem_scene = preload("res://scenes/ExpGem.tscn")

func glow():
#	glow_sprite.visible = true
	#modulate = Color(1, 0, 0, 1)
	await get_tree().create_timer(0.2).timeout
	#modulate = enemy_color
	#glow_sprite.visible = false
	
func dead():
	#if sprite_node.get_animation() == "dead":
	var gem_instance = exp_gem_scene.instantiate()
	var explosion = gem_instance.get_node("AnimatedSprite3D")
	
	
	gem_instance.global_position = global_position
	#gem_instance.global_position.z = 5
	EnemyManager.add_child(gem_instance)
	explosion.play("explosion")
	EnemyManager.enemies.erase(self)
	self.queue_free()
