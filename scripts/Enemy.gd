extends KinematicBody

var speed = 5.0  # Adjust as needed
var pushing_strength = 5.0
var HP = 3 # hit points
var power = 1
var distance_to_hero = -1
var enemy_color = Color(.9, .8, 1, 1)
#var ISO = Vector2(1, .5)  # isometric coordinate transform
#var unISO = Vector2(1, 2) # undo isometric coordinate transform

var sprite_offset = Vector3()

onready var blue_orb = WeaponManager.BlueOrbEmitter
onready var smooth_node = $PositionSmoother
onready var sprite_node = $PositionSmoother/Stan
onready var killsound = $AudioStreamPlayer2D
onready var weapons = WeaponManager.weapons

func _ready():
	sprite_node.connect("animation_finished", self, "_on_animation_finished")
	#sprite_node.speed_scale = speed / 300.0
	sprite_offset = smooth_node.translation
	#modulate = enemy_color

func _physics_process(delta):
	distance_to_hero = global_translation.distance_to(Hero.global_translation)
	var gap_vector = Hero.global_translation - global_translation
	var direction = (gap_vector).normalized()
	var start_position = global_translation
	var sprite_start_position = smooth_node.translation  # Save the current position before moving
	
	if HP > 0:
		var real_gap_vector = gap_vector #* unISO #de-isometricify before using the angle
		var angle = atan2(real_gap_vector.y, real_gap_vector.x)
		var angle_dir = int(angle / (PI / 4)) % 8
		sprite_node.play("walk_"+["e","se","s","sw","w","nw","n","ne"][angle_dir])
	
	# First, try to move normally.	
	var push_vector = Vector3.ZERO
	var recoil = Vector3.ZERO
	var collision = move_and_collide(direction * speed * delta)

	if collision:
		if weapons.has(collision.collider):
			HP -= collision.collider.power
			recoil = (Hero.global_translation - global_translation).normalized() * 100
			glow()
			if HP <= 0:
				speed = 0
				killsound.play()
				sprite_node.play("dead")
				# remove from collision layers
				set_collision_layer_bit(0, false)
				set_collision_mask_bit(0, false)
				set_collision_layer_bit(1, false)
				set_collision_mask_bit(1, false)
				EnemyManager.enemies.erase(self)

			
		# Attempt to push the collider by manually adjusting the enemy's global_position
		push_vector = collision.remainder.normalized() * pushing_strength * delta
	
	var new_position = global_translation + push_vector - recoil
	var smoothed_position = (start_position + sprite_start_position).linear_interpolate(new_position + sprite_offset, 0.3)
	global_translation = global_translation + (new_position - global_translation) #* ISO 
	smooth_node.translation = smoothed_position - new_position	
		
	#self.z_index = int(smoothed_position.y - Cam.global_translation.y)

var exp_gem_scene = preload("res://scenes/ExpGem.tscn")

func glow():
#	glow_sprite.visible = true
	#modulate = Color(1, 0, 0, 1)
	yield(get_tree().create_timer(0.2), "timeout")
	#modulate = enemy_color
	#glow_sprite.visible = false
	
func _on_animation_finished():
	if sprite_node.get_animation() == "dead":
		var gem_instance = exp_gem_scene.instance()
		gem_instance.global_translation = global_translation
		EnemyManager.add_child(gem_instance)
		EnemyManager.enemies.erase(self)
		self.queue_free()
