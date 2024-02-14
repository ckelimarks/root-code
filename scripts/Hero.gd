extends CharacterBody3D

# ATTRIBUTES
#stats
var min_stats = {
	"luck": 1.0,
	"speed": 26.0,
	"max_HP": 100.0,
	"defense": 0,
	"health_regen": 0.1,
	"pushing_strength": 10.0,
}
var luck = min_stats.luck
var speed = min_stats.speed
var max_HP = min_stats.max_HP
var defense = min_stats.defense
var health_regen = min_stats.health_regen
var pushing_strength = min_stats.pushing_strength
var HP = max_HP
#movement
var woke = false
var target_angle = PI/2
var angle = target_angle
var throttle = 0.0
var dampening = 0.8

# NODES AND SCENES
#local
@onready var HealthBar        = $HealthBar
@onready var Emp              = $Emp
@onready var OrbOrigin        = $OrbOrigin
@onready var Robot            = $Stan
@onready var AnimPlayer       = $Stan/AnimationPlayer
@onready var AnimTree         = $Stan/AnimationTree
@onready var SwordCollision   = $Stan/RobotArmature/Skeleton3D/BoneAttachment3D/Sword/CollisionShape3D
# autoload these?, and put these vars in their top-level scopes
# external
@onready var MainNode = get_node("/root/Main")
@onready var XpBar = get_node("/root/Main/UICanvas/XpBar")
@onready var YouDied = get_node("/root/Main/UICanvas/YouDied")
#@onready var game_over = get_node("/root/Main/GameOverSound")
@onready var FocusButton = get_node("/root/Main/UICanvas/MarginContainer/VBoxContainer/Button1")
@onready var Music = get_node("/root/Main/Music")

var Sword: CharacterBody3D  
var SwordScene = preload("res://scenes/weapons/Sword.tscn")

func _ready():
	var RobotCollider = Robot.get_node("Collider")
	AnimTree.set_active(true)
	$Collider.set_shape(RobotCollider.shape)
	$Collider.position = RobotCollider.position
	$Collider.rotation = RobotCollider.rotation
	sleepen()
	
func sleepen():
	if Sword: Sword.queue_free()
	$HealthRing.set_visible(false)
	#HealthBar.set_visible(false)
	Robot.get_node("%ThirdEye").set_visible(false)
	AnimTree.set("parameters/Tree/WalkSpeed/scale", 8.0 / 12.0)
	AnimTree.set("parameters/Tree/BlendMove/blend_amount", 1)
	
func awaken():
	$HealthRing.visible = true
	Robot.get_node("%ThirdEye").set_visible(true)
	Emp.enabled = true
	var SwordHolder = Robot.get_node("%SwordHolder")
	Sword = SwordScene.instantiate()
	WeaponManager.weapons.append(Sword)
	SwordHolder.add_child(Sword)
	#HealthBar.set_visible(true)
	woke = true
	#print_tree_properties(AnimTree, "")

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
	update_animation_parameters()
	HP = min(max_HP, HP + health_regen * delta)
	if !woke: global_position += Vector3(0, 0, delta*8.0)
	global_position.y = 0
	$HealthRing/Red.material.set_shader_parameter("health", HP/max_HP)

func updateMomentum():
	throttle *= .1
	velocity *= Vector3(dampening, 0, dampening)
	velocity += Vector3(cos(angle), 0, sin(angle)) * throttle * speed
	
	# Adjust target_angle for the shortest rotation path and update angle
	angle = fposmod(angle + PI, 2*PI) - PI
	target_angle = angle + fposmod(target_angle - angle + PI, 2*PI) - PI
	angle = move_toward(angle, target_angle, PI/24)
	Robot.rotation.y = -angle + PI/2

var previous_horizontal_direction = 0
var previous_vertical_direction = 0
func getUserInteraction():
	# int(bool) turns true into 1 and false into 0
	var right = int(Input.is_action_pressed('ui_right'))
	var left = int(Input.is_action_pressed('ui_left'))
	var up = int(Input.is_action_pressed('ui_up'))
	var down = int(Input.is_action_pressed('ui_down'))
	var slash = Input.is_action_just_pressed("attack")
	
	#InputEventScreenTouch.
	if slash and woke: Sword.slash()
	
	var x = right - left
	var y = down - up
	var bias_amount = PI/256
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

	if (slash or x or y) and !woke: awaken()

func handleMovementAndCollisions(delta):
	# First, try to move normally.
	var collision = move_and_collide(velocity * delta)
	var push_vector = Vector3.ZERO
	
	#sprite_node.modulate = Color(1, 1, 1, 1)
	
	if collision:
		var collider = collision.get_collider()
		
		if collider.is_in_group("enemies"):
			$ImpactSound.play()
			HP -= collider.damage
			#sprite_node.modulate = Color(1, 0, 0, 1)
			if HP <= 0:
				die()
				return

		# Attempt to push the collider by manually adjusting the hero's global_position
		push_vector = collision.get_remainder().normalized() * pushing_strength * delta
	
	global_position += push_vector
	global_position.y = 1

func die():
	Music.stop()
	SoundManager.GameOverSound.play()
	YouDied.show()
	#AudioServer.set_bus_effect_enabled(0, 0, true)
	get_tree().paused = true
	
	#focusbutton.grab_focus()
	#main_node.reset()
	XpBar.value = 0
	
func get_slash_curve(x):
	# https://www.desmos.com/calculator/zh8hnxofkx -- cosine based
	var a = 4.0 # { a > 2, a%2 == 0 }
	var y = (1 - cos(a*PI*x)) / 2
	if x > 1/a and x < 1-1/a: y = 1.0
	return y
	
func update_animation_parameters():
	if !woke: return
	var speed_percent = velocity.length() * 2 / speed
	var slash_speed = 1
	var slash_progress = minf(Sword.slash_progress*slash_speed, 1)
	var slash_duration = Sword.slash_duration
	var slash_blend = get_slash_curve(slash_progress)
	AnimTree.set("parameters/Tree/BlendMove/blend_amount", speed_percent)
	AnimTree.set("parameters/Tree/BlendSlash/blend_amount", slash_blend)
	AnimTree.set("parameters/Tree/BlendWalkSlash/blend_amount", slash_blend * speed_percent)
	#AnimTree.set("parameters/Tree/Idle/time", x)
	AnimTree.set("parameters/Tree/Slash/time", slash_progress * slash_duration)
	#AnimTree.set("parameters/Tree/WalkHold/time", x)
	AnimTree.set("parameters/Tree/WalkSlash/time", slash_progress * slash_duration)
	AnimTree.set("parameters/Tree/WalkSpeed/scale", velocity.length() / 12)
	
