extends CharacterBody3D

# ATTRIBUTES
#	stats
var min_stats = {
	"luck":             1.0,
	"speed":           26.0,
	"max_HP":         100.0,
	"defense":          0.0,
	"health_regen":     0.1,
	"pushing_strength": 0.0,
}
var exp               = 0
var luck              = min_stats.luck
var speed             = min_stats.speed
var max_HP            = min_stats.max_HP #+999999
var defense           = min_stats.defense
var health_regen      = min_stats.health_regen
var current_level     = 0
var pushing_strength  = min_stats.pushing_strength
var upgrade_threshold = 10
var HP                = 1#max_HP
#	movement
var touch = {
	"left":   false,
	"right":  false,
	"up":     false,
	"down":   false,
	"attack": false
}
var previous_horizontal_direction = 0
var previous_vertical_direction = 0
var woke         = false
var dead         = false
var mass         = 10.0
var throttle     = 0.0
var momentum     = Vector3.ZERO
var dampening    = 0.8
var target_angle = PI/2
var action       = false
var angle        = target_angle
var position_delta = Vector3.ZERO
var eye_material

# NODES AND SCENES
#	local
@onready var HealthBar        = $HealthBar
@onready var Emp              = $Emp
@onready var OrbOrigin        = $OrbOrigin
@onready var Robot            = $Stan
@onready var AnimPlayer       = $Stan/AnimationPlayer
@onready var AnimTree         = $Stan/AnimationTree
@onready var SwordCollision   = $Stan/RobotArmature/Skeleton3D/BoneAttachment3D/Sword/CollisionShape3D
#	external
@onready var XpBar        = UI.XpBar
@onready var RestartModal = UI.RestartModal
@onready var UpgradeModal = UI.UpgradeModal
# autoload these?, and put these vars in their top-level scopes
#@onready var game_over = get_node("/root/Main/GameOverSound")
@onready var Music        = get_node("/root/Main/Music")
@onready var MainNode     = get_node("/root/Main")

var Sword: CharacterBody3D
var SwordScene = preload("res://scenes/weapons/Sword.tscn")
var SwordHolder: Node3D
var punch = 0.0
var punching = false

func _ready():
	await Mainframe.intro("Hero")

	var RobotCollider = Robot.get_node("Collider")
	var FistCollider  = Robot.get_node("%Fist/Collider")
	SwordHolder       = Robot.get_node("%SwordHolder")
	FistCollider.disabled = true
	AnimTree.set_active(true)
	$Collider.set_shape(RobotCollider.shape)
	$Collider.position = RobotCollider.position
	$Collider.rotation = RobotCollider.rotation
	#global_position.x = 2000

	eye_material = Robot.get_node("%LeftEye").get_active_material(0).duplicate()
	eye_material.emission = "#00ff00"
	Robot.get_node("%LeftEye").material_override = eye_material
	Robot.get_node("%RightEye").material_override = eye_material

	print_tree_properties(AnimTree, "")

	#sleepen()

func sleepen():
	woke                                = false
	Emp.enabled                         = false
	Robot.get_node("%ThirdEye").visible = false
	Robot.get_node("%LeftEye").get_active_material(0).emission = "#ff0000"
	Robot.get_node("%RightEye").get_active_material(0).emission = "#ff0000"


	if is_instance_valid(Sword):
		Sword.get_parent().remove_child(Sword)
		EcologyManager.add_child(Sword)
		#if !is_instance_valid(EcologyManager.Sword):
			#EcologyManager.Sword = SwordScene.instantiate()
		#Sword.queue_free()
		#WeaponManager.weapons.erase(Sword)

	$HealthRing.visible = false
	#HealthBar.set_visible(false)

	#AnimTree.set("parameters/Tree/WalkSpeed/scale", 8.0 / 12.0)
	#AnimTree.set("parameters/Tree/BlendMove/blend_amount", 1)

func awaken():
	woke                                = true
	Emp.enabled                         = true
	Robot.get_node("%ThirdEye").visible = true
	#Robot.get_node("%Spotlight").light_color = "#39afea"
	Robot.get_node("%LeftEye").get_active_material(0).emission = "#00c4f6"
	Robot.get_node("%RightEye").get_active_material(0).emission = "#00c4f6"
	$HealthRing.visible = true
	activate_sword()
	
func activate_sword():
	#if !is_instance_valid(EcologyManager.Sword):
		#EcologyManager.Sword = SwordScene.instantiate()
	Sword = EcologyManager.Sword
	Sword.get_parent().remove_child(Sword)
	SwordHolder.add_child(Sword)
	Sword.global_position = SwordHolder.global_position
	Sword.global_rotation = SwordHolder.global_rotation
	Sword.scale = Vector3(0.1, 0.1, 0.1)
	WeaponManager.weapons.append(Sword)
	#HealthBar.set_vis6ible(true)

func print_tree_properties(object, path):
	for property in object.get_property_list():
		var property_path = path + "/" + property.name
		print(property_path)
		var property_value = object.get(property.name)
		if property_value is AnimationNode:
			print_tree_properties(property_value, property_path)

func _physics_process(delta):
	updateMomentum()
	getUserInteraction()
	handleMovementAndCollisions(delta)
	update_animation_parameters(delta)
	HP = min(max_HP, HP + health_regen * delta)
	global_position = EcologyManager.altitude_at(global_position)
	$HealthRing/H1/HP.material.set_shader_parameter("HP", HP/1000)
	$HealthRing/H1/HP.material.set_shader_parameter("max_HP", max_HP/1000) #rotation.y = -min(1000, max_HP/1000 * 2*PI)
	#if HP <= 100:
		#$HealthRing/H2.visible = false
		#$HealthRing/H1/Red.visible = true
		#$HealthRing/H1/RedFull.visible = false
		#$HealthRing/H1/Red.material.set_shader_parameter("health", HP/100)
	#else:
		#$HealthRing/H2.visible = true
		#$HealthRing/H1/Red.visible = false
		#$HealthRing/H1/RedFull.visible = true
		#$HealthRing/H2/Red.material.set_shader_parameter("health", HP/100-1)
		
		
	if HP <= 0: die()

func updateMomentum():
	# Adjust target_angle for the shortest rotation path and update angle
	angle            = fposmod(angle + PI, 2*PI) - PI
	target_angle     = angle + fposmod(target_angle - angle + PI, 2*PI) - PI
	angle            = move_toward(angle, target_angle, PI/24)
	Robot.rotation.y = -angle + PI/2

	throttle *= .1
	velocity *= Vector3(dampening, 0, dampening)
	velocity += Vector3(cos(angle), 0, sin(angle)) * throttle * speed

func getUserInteraction():
	# int(bool) turns true into 1 and false into 0
	var right = int(Input.is_action_pressed('ui_right') || touch.right)
	var left  = int(Input.is_action_pressed('ui_left')  || touch.left)
	var up    = int(Input.is_action_pressed('ui_up')    || touch.up)
	var down  = int(Input.is_action_pressed('ui_down')  || touch.down)
	var slash = Input.is_action_just_pressed("attack")  || touch.attack

	#InputEventScreenTouch.
	if slash and woke and is_instance_valid(Sword): Sword.slash()
	elif slash and woke and punch < 0.3: punching = true

	var x = right - left
	var y = down - up
	var bias_amount = PI/1024
	
	if dead and (right or left or up or down or slash):
		x = -1
		y = -1
	
	if x or y:
		var bias = 0
		if x:
			bias = bias_amount * previous_vertical_direction * sign(x)
			previous_horizontal_direction = x

		if y:
			bias = bias_amount * previous_horizontal_direction * sign(-y)
			previous_vertical_direction = y

		target_angle = atan2(y, x)
		angle -= bias
		throttle = 1.0

	#if !woke: # lerp interaction and default march based on wokeness
		#target_angle = 3*PI/4
		#throttle = 0.625 # don't do it this way
		
	if (slash or x or y): action = true
	else: action = false

func handleMovementAndCollisions(delta):
	momentum *= Vector3(.95, .95, .95)
	if dead: return
	# First, try to move normally.
	var start_position = global_position
	var collision = move_and_collide(velocity * delta)
	var push_vector = Vector3.ZERO

	#sprite_node.modulate = Color(1, 1, 1, 1)
	momentum *= Vector3(.95, .95, .95)

	if collision:
		var collider = collision.get_collider()

		if collider.is_in_group("enemies"):
			$ImpactSound.play()
			sparks()
			SoundManager.ImpactSound.play()
			#HP -= collider.damage/2
			sparks()
			#sprite_node.modulate = Color(1, 0, 0, 1)

		# Attempt to push the collider by manually adjusting the hero's global_position
		push_vector = collision.get_remainder().normalized() * pushing_strength * delta

	global_position += push_vector + momentum
	global_position = EcologyManager.altitude_at(global_position)
	position_delta = position_delta.lerp((global_position - start_position) / delta, 0.3)

func sparks():
	if dead:
		pass
	elif is_instance_valid($Stan/%Sparks):
		var Sparks = $Stan/%Sparks
		Sparks.emitting = true

func die():
	if dead: return
	Music.stop()
	SoundManager.GameOverSound.play()
	UI.RestartModal.show()
	AudioServer.set_bus_effect_enabled(SoundManager.BUS_MUSIC, 0, true)
	#get_tree().paused = true
	#main_node.reset()
	punching = false
	dead = true
	Console.transfer_delay = 1
	MainNode.reset_begin()
	UI.XpBar.value = 0

func get_slash_curve(x):
	# https://www.desmos.com/calculator/zh8hnxofkx -- cosine based
	var a = 4.0 # { a > 2, a%2 == 0 }
	var y = (1 - cos(a*PI*x)) / 2
	if x > 1/a and x < 1-1/a: y = 1.0
	return y

func update_animation_parameters(delta):
	var speed_percent = position_delta.length() * 2 / speed
	if is_instance_valid(Sword):
		var slash_speed = 1
		var slash_progress = minf(Sword.slash_progress*slash_speed, 1)
		var slash_duration = Sword.slash_duration
		var slash_blend = get_slash_curve(slash_progress)
		AnimTree.set("parameters/Tree/Slash/time", slash_progress * slash_duration)
		AnimTree.set("parameters/Tree/WalkSlash/time", slash_progress * slash_duration)
		AnimTree.set("parameters/Tree/BlendSlash/blend_amount", slash_blend)
		AnimTree.set("parameters/Tree/BlendWalkSlash/blend_amount", slash_blend * speed_percent)
	else:
		AnimTree.set("parameters/Tree/BlendSlash/blend_amount", 0)
		AnimTree.set("parameters/Tree/BlendWalkSlash/blend_amount", 0)
	
	if punching:
		AnimTree.set("parameters/Tree/BlendPunch/blend_amount", min(1, punch*2))
		AnimTree.set("parameters/Tree/Punch/time", punch)
		punch += delta
		#punch = min(0.7083, punch + delta)
		if punch > 0.7: punching = false
	else:
		punch*=0.9
		AnimTree.set("parameters/Tree/BlendPunch/blend_amount", min(1, punch))

	#AnimTree.set("parameters/Tree/Idle/time", x)
	#AnimTree.set("parameters/Tree/WalkHold/time", x)
	AnimTree.set("parameters/Tree/BlendMove/blend_amount", speed_percent)
	AnimTree.set("parameters/Tree/WalkSpeed/scale", velocity.length() / 12)
