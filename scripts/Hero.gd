extends CharacterBody3D

# ATTRIBUTES
#	stats
var min_stats = {
	"luck":               1.0,
	"speed":             26.0,
	"max_HP":           100.0,
	"defense":            0.0,
	"health_regen":       0.1,
	"pushing_strength":  0.0,
}
var luck             = min_stats.luck
var speed            = min_stats.speed
var max_HP           = min_stats.max_HP#+999999
var defense          = min_stats.defense
var health_regen     = min_stats.health_regen
var pushing_strength = min_stats.pushing_strength
var HP               = max_HP
var current_level    = 0
#	movement
var touch = {
	"left":   false,
	"right":  false,
	"up":     false,
	"down":   false,
	"attack": false
}
var woke         = false
var mass         = 10.0
var throttle     = 0.0
var momentum     = Vector3.ZERO
var dampening    = 0.8
var target_angle = PI/2
var wakefullness = 0.0
var angle        = target_angle

# NODES AND SCENES
#	local
@onready var HealthBar        = $HealthBar
@onready var Emp              = $Emp
@onready var OrbOrigin        = $OrbOrigin
@onready var Robot            = $Stan
@onready var AnimPlayer       = $Stan/AnimationPlayer
@onready var AnimTree         = $Stan/AnimationTree
@onready var SwordCollision   = $Stan/RobotArmature/Skeleton3D/BoneAttachment3D/Sword/CollisionShape3D
# autoload these?, and put these vars in their top-level scopes
#	external
@onready var XpBar        = UI.XpBar
@onready var RestartModal = UI.RestartModal
@onready var UpgradeModal = UI.UpgradeModal
#@onready var game_over = get_node("/root/Main/GameOverSound")
@onready var Music        = get_node("/root/Main/Music")
@onready var MainNode     = get_node("/root/Main")

var Sword: CharacterBody3D  
var SwordScene = preload("res://scenes/weapons/Sword.tscn")
var SwordHolder: Node3D

func _ready():
	var RobotCollider = Robot.get_node("Collider")
	var FistCollider  = Robot.get_node("%Fist/Collider")
	SwordHolder       = Robot.get_node("%SwordHolder")
	FistCollider.disabled = true
	AnimTree.set_active(true)
	$Collider.set_shape(RobotCollider.shape)
	$Collider.position = RobotCollider.position
	$Collider.rotation = RobotCollider.rotation
	sleepen()
	
func sleepen():
	woke                                = false
	Emp.enabled                         = false
	Robot.get_node("%ThirdEye").visible = false
	
	if is_instance_valid(Sword): 
		Sword.queue_free()
		WeaponManager.weapons.erase(Sword)
	
	$HealthRing.set_visible(false)
	#HealthBar.set_visible(false)
	
	AnimTree.set("parameters/Tree/WalkSpeed/scale", 8.0 / 12.0)
	AnimTree.set("parameters/Tree/BlendMove/blend_amount", 1)
	
func awaken():
	woke                                = true
	Emp.enabled                         = true
	Robot.get_node("%ThirdEye").visible = true

	Sword = SwordScene.instantiate()
	SwordHolder.add_child(Sword)
	WeaponManager.weapons.append(Sword)
	$HealthRing.visible = true
	#HealthBar.set_vis6ible(true)
	#print_tree_properties(AnimTree, "")

func print_tree_properties(object, path):
	for property in object.get_property_list():
		var property_path = path + "/" + property.name
		print(property_path)
		var property_value = object.get(property.name)
		if property_value is AnimationNode:
			print_tree_properties(property_value, property_path)

func _physics_process(delta):
	if woke: updateMomentum()
	getUserInteraction()
	handleMovementAndCollisions(delta)
	update_animation_parameters()
	HP = min(max_HP, HP + health_regen * delta)
	if !woke: global_position += Vector3(0, 0, delta*8.0)
	global_position.y = 0
	$HealthRing/Red.material.set_shader_parameter("health", HP/max_HP)
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

var previous_horizontal_direction = 0
var previous_vertical_direction = 0
func getUserInteraction():
	# int(bool) turns true into 1 and false into 0
	var right = int(Input.is_action_pressed('ui_right') || touch.right)
	var left  = int(Input.is_action_pressed('ui_left')  || touch.left)
	var up    = int(Input.is_action_pressed('ui_up')    || touch.up)
	var down  = int(Input.is_action_pressed('ui_down')  || touch.down)
	var slash = Input.is_action_just_pressed("attack")  || touch.attack
	
	#InputEventScreenTouch.
	if slash and woke: Sword.slash()
	
	var x = right - left
	var y = down - up
	var bias_amount = PI/1024
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

	if (slash or x or y):
		wakefullness += 1
		if !woke:
			print(wakefullness)
			if randf() > 1-wakefullness: awaken()
		else:
			if randf() > wakefullness: sleepen()

func handleMovementAndCollisions(delta):
	# First, try to move normally.
	var collision = move_and_collide(velocity * delta)
	var push_vector = Vector3.ZERO

	#sprite_node.modulate = Color(1, 1, 1, 1)
	momentum *= Vector3(.95, .95, .95)

	if collision:
		var collider = collision.get_collider()
		
		if collider.is_in_group("enemies"):
			$ImpactSound.play()
			HP -= collider.damage/2
			sparks()
			#sprite_node.modulate = Color(1, 0, 0, 1)

		# Attempt to push the collider by manually adjusting the hero's global_position
		push_vector = collision.get_remainder().normalized() * pushing_strength * delta
	
	global_position += push_vector + momentum
	global_position.y = 1

func sparks():
	if is_instance_valid($Stan/%Sparks):
		var Sparks = $Stan/%Sparks
		Sparks.emitting = true

func die():
	Music.stop()
	SoundManager.GameOverSound.play()
	UI.RestartModal.show()
	AudioServer.set_bus_effect_enabled(1, 0, true)
	get_tree().paused = true
	
	#main_node.reset()
	UI.XpBar.value = 0
	
func get_slash_curve(x):
	# https://www.desmos.com/calculator/zh8hnxofkx -- cosine based
	var a = 4.0 # { a > 2, a%2 == 0 }
	var y = (1 - cos(a*PI*x)) / 2
	if x > 1/a and x < 1-1/a: y = 1.0
	return y
	
func update_animation_parameters():
	if !woke: return
	var speed_percent = velocity.length() * 2 / speed
	
	if is_instance_valid(Sword):
		var slash_speed = 1
		var slash_progress = minf(Sword.slash_progress*slash_speed, 1)
		var slash_duration = Sword.slash_duration
		var slash_blend = get_slash_curve(slash_progress)
		AnimTree.set("parameters/Tree/Slash/time", slash_progress * slash_duration)
		AnimTree.set("parameters/Tree/WalkSlash/time", slash_progress * slash_duration)
		AnimTree.set("parameters/Tree/BlendSlash/blend_amount", slash_blend)
		AnimTree.set("parameters/Tree/BlendWalkSlash/blend_amount", slash_blend * speed_percent)
	#AnimTree.set("parameters/Tree/Idle/time", x)
	#AnimTree.set("parameters/Tree/WalkHold/time", x)
	AnimTree.set("parameters/Tree/BlendMove/blend_amount", speed_percent)
	AnimTree.set("parameters/Tree/WalkSpeed/scale", velocity.length() / 12)
	
