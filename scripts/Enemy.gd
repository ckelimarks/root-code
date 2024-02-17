extends CharacterBody3D

# ATTRIBUTES
#	local
var HP                       = 10 # hit points
var mass                     = 1.0
var speed                    = 10.0  # Adjust as needed
var damage                   = 1.0
var is_dead                  = false
var swarm_id                 = randf()
var momentum                 = Vector3.ZERO
var behaviour                = "attack" # assist, march, swarm ... etc
var knock_back               = 1.0
var enemy_color              = Color(.9, .8, 1, 1)
var pushing_strength         = 0.0
var platoon_grid_position:     Vector2
#	external
@onready var weapons         = WeaponManager.weapons

# NODES
#	local
@onready var Explosion       = $Explosion
#	external
@onready var Robot:            CharacterBody3D
@onready var KillSound       = SoundManager.KillSound
@onready var BlueOrbEmitter  = WeaponManager.BlueOrbEmitter
@onready var RobotAnimation:   AnimationPlayer

# SCENES
var ExpGemScene              = preload("res://scenes/items/ExpGem.tscn")
var ExplosionScene           = preload("res://scenes/weapons/Explosion.tscn")

func _ready():
	var RobotCollider = Robot.get_node("Collider")
	add_child(Robot)
	$Collider.set_shape(RobotCollider.shape)
	$Collider.position = RobotCollider.position
	$Collider.rotation = RobotCollider.rotation
	SoundManager.MarchSound.pitch_scale = .7
	SoundManager.MarchSound.play()

func _physics_process(delta):
	if is_dead:
		return
		
	var start_position = global_position
	var gap_vector = Hero.global_position - global_position
	var direction: Vector3

	# these behaviours should get outsourced to story/<BEHAVIOUR_TYPE>.gd scripts
	# including speed adjustments, and animation modes (stan stops and melees for example)
	if behaviour == "attack":
		direction = (gap_vector).normalized()
		
		if is_instance_valid($Stan/AnimationTree):
			var AnimTree = $Stan/AnimationTree
			AnimTree.active = true
			if gap_vector.length() < 5:
				AnimTree.set("parameters/Tree/BlendSlash/blend_amount", 1.0)
				AnimTree.set("parameters/Tree/BlendMove/blend_amount", 0.0)
			else:
				AnimTree.set("parameters/Tree/BlendSlash/blend_amount", 0.0)
				AnimTree.set("parameters/Tree/BlendMove/blend_amount", 1.0)

		# KELI -- this shouldn't go here:
		#SoundManager.MarchSound.stop() 
		# it will trigger this every frame
		# for every enemy in this attack mode
	elif behaviour == "swarm":
		direction = (gap_vector).normalized()
		if gap_vector.length() < 10: behaviour = "swarm_away"
	elif behaviour == "swarm_away":
		direction.x = cos(global_rotation.y - PI/2)
		direction.z = -sin(global_rotation.y - PI/2)
	elif behaviour == "march":
		direction = Vector3(0, 0, 1)

	global_position.y = 0
	global_rotation.y = atan2(-direction.z, direction.x) + PI / 2

	# First, try to move normally.
	var push_vector = Vector3.ZERO
	var collision = move_and_collide(direction * speed * delta)

	momentum *= Vector3(.95, .95, .95)

	if collision:
		var collider = collision.get_collider()
		
		if (collider == Hero or weapons.has(collider)) and behaviour == "march":
			behaviour = "attack"
			speed = 10
			EnemyManager.Platoon.platoon_holes[platoon_grid_position] = true
			EnemyManager.rogue_alert_on = true
		
		if weapons.has(collider):
			SoundManager.StrikeSound.play()
			SoundManager.StrikeSound.volume_db = -12 + collider.power * 3
			HP -= collider.damage
			momentum += (global_position - Hero.global_position).normalized() * sqrt(collider.knock_back / 2) / mass
			glow()
			if HP <= 0: dead()
			
		# Attempt to push the collider by manually adjusting the enemy's global_position
		push_vector = collision.get_remainder().normalized() * pushing_strength * delta
	
	global_position += push_vector + momentum

func glow():
	pass
	#glow_sprite.visible = true
	#modulate = Color(1, 0, 0, 1)
	#await get_tree().create_timer(0.2).timeout
	#modulate = enemy_color
	#glow_sprite.visible = false
	
func dead():
	var gem_instance       = ExpGemScene.instantiate()
	var explosion_instance = ExplosionScene.instantiate()
	
	$Collider.disabled = true
	is_dead            = true
	speed              = 0
	KillSound.play()
	#enemy_node.play("dead")
	
	# remove from collision layers
	set_collision_layer_value(0, false)
	set_collision_mask_value(0, false)
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	EnemyManager.enemies.erase(self)
	EnemyManager.add_child(gem_instance)
	EnemyManager.add_child(explosion_instance)

	gem_instance.global_position       = global_position
	explosion_instance.global_position = global_position

	self.queue_free()
