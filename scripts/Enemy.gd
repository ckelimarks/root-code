extends CharacterBody3D

# TODO: make stan and fist not monitor or monitorable when marching
# if Hero enters avoidance area, turn on stan
# if attack mode, turn on fist

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

var punching = 0.0
func _physics_process(delta):
	if is_dead:
		return
		
	var start_position = global_position
	var gap_vector = Hero.global_position - global_position
	var direction: Vector3

	# these behaviours should get outsourced to story/<BEHAVIOUR_TYPE>.gd scripts
	# including speed adjustments, and animation modes (stan stops and melees for example)
	if behaviour == "attack":
		# remove guards from guard group?
		#Robot.global_rotation.y = 0
		direction = (gap_vector).normalized()
		
		if is_instance_valid($Stan/AnimationTree):
			var AnimTree = $Stan/AnimationTree
			AnimTree.active = true
			AnimTree.set("parameters/Tree/BlendMove/blend_amount", 1-punching)
			AnimTree.set("parameters/Tree/BlendPunch/blend_amount", punching)
			if gap_vector.length() < 5:
				punching  = min(1, punching + delta * 3)
			else:
				punching = max(0, punching - delta * 3)

		# KELI -- this shouldn't go here:
		SoundManager.MarchSound.stop() 
		# it will trigger this every frame
		# for every enemy in this attack mode
	elif behaviour == "swarm":
		direction = (gap_vector).normalized()
		if gap_vector.length() < 10: behaviour = "swarm_away"
	elif behaviour == "swarm_away":
		direction.x = cos(global_rotation.y - PI/2)
		direction.z = -sin(global_rotation.y - PI/2)
	elif behaviour == "march":
		direction = Vector3(-1, 0, 1).normalized()
	elif behaviour == "guard":
		pass
		#direction = Vector3(-1, 0, 1).normalized()

	global_position = EcologyManager.altitude_at(global_position)
	if behaviour != "guard":
		global_rotation.y = atan2(-direction.z, direction.x) + PI / 2

	# First, try to move normally.
	var push_vector = Vector3.ZERO
	#speed=0
	var collision = move_and_collide(direction * speed * delta)

	momentum *= Vector3(.95, .95, .95)

	if collision:
		var collider = collision.get_collider()
		
		if collider == Hero or weapons.has(collider): # and behaviour == "march":
			behaviour = "attack"
			speed = 10
			#EnemyManager.Platoon.platoon_holes[platoon_grid_position] = true
			EnemyManager.rogue_alert_on = true
		
		if collider == Hero:
			Hero.HP -= damage/2
			SoundManager.ImpactSound.play()
			Hero.sparks()
			
		if weapons.has(collider):
			SoundManager.StrikeSound.play()
			SoundManager.StrikeSound.volume_db = -12 + collider.power * 3
			#if is_instance_valid($Stan/AnimationTree):
				#var AnimTree = $Stan/AnimationTree
				#AnimTree.set("parameters/Tree/Hit/time", 0.0)
				#AnimTree.set("parameters/Tree/BlendHit/blend_amount", 1.0)
				#await get_tree().create_timer(0.5).timeout
				#AnimTree.set("parameters/Tree/BlendHit/blend_amount", 0.0)
				
			HP -= collider.damage
			momentum += (global_position - Hero.global_position).normalized() * sqrt(collider.knock_back / 2) / mass
			sparks()
			if HP <= 0: dead()
			
		# Attempt to push the collider by manually adjusting the enemy's global_position
		push_vector = collision.get_remainder().normalized() * pushing_strength * delta
	
	#global_position += push_vector + momentum
	global_position += momentum

func sparks():
	if is_instance_valid($Stan/%Sparks):
		var Sparks = $Stan/%Sparks
		Sparks.emitting = true

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
