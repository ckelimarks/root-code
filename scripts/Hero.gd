extends CharacterBody3D

#stats
var HP = 100.0
var max_HP = 100.0
var speed = 24.0
var defense = 0
var pushing_strength = 10.0
var health_regen = 0.1
var luck = 1

#movement
var angle = 0.0
var target_angle = 0.0
var throttle = 0.0
var dampening = 0.8

#local nodes
@onready var HeroHealth       = $HealthNode/HeroHealth
@onready var Emp              = $Emp
@onready var OrbOrigin        = $OrbOrigin
@onready var robot            = $Stan
@onready var animation_player = $Stan/AnimationPlayer
@onready var animation_tree   = $Stan/AnimationTree
@onready var sword_collision  = $Stan/RobotArmature/Skeleton3D/BoneAttachment3D/Sword/CollisionShape3D

# autoload these, and put these vars in their top-level scopes
@onready var main_node = get_node("/root/Main")
@onready var xp_bar = get_node("/root/Main/UICanvas/xpBar")
@onready var you_died = get_node("/root/Main/UICanvas/youdied")
@onready var game_over = get_node("/root/Main/GameOverSound")
@onready var focusbutton = get_node("/root/Main/UICanvas/MarginContainer/VBoxContainer/Button1")
@onready var music = get_node("/root/Main/Music")

var Sword: CharacterBody3D  
#var Emp: 

func _ready():
	animation_tree.active = true
	var robot_collider = robot.get_node("Collider")
	$Collider.set_shape(robot_collider.shape)
	$Collider.position = robot_collider.position
	$Collider.rotation = robot_collider.rotation
	Sword = robot.get_node("%Sword")
	#print_tree_properties(animation_tree, "")

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
	position_healthbar()

func updateMomentum():
	throttle *= .1
	velocity *= Vector3(dampening, 0, dampening)
	velocity += Vector3(cos(angle), 0, sin(angle)) * throttle * speed
	
	# Adjust target_angle for the shortest rotation path and update angle
	angle = fposmod(angle + PI, 2*PI) - PI
	target_angle = angle + fposmod(target_angle - angle + PI, 2*PI) - PI
	angle = move_toward(angle, target_angle, PI/24)
	robot.rotation.y = -angle + PI/2

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
	if slash: Sword.slash()
	
	var x = right - left
	var y = down - up
	if x or y:
		var bias = 0
		if x:
			bias = PI/36 * previous_vertical_direction * sign(x)
			previous_horizontal_direction = x

		if y:
			bias = PI/36 * previous_horizontal_direction * sign(-y)
			previous_vertical_direction = y

		target_angle = atan2(y, x)
		angle -= bias
		throttle = 1.0

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
			HeroHealth.value = HP / max_HP * 100
			if HP <= 0:
				die()
				return

		# Attempt to push the collider by manually adjusting the hero's global_position
		push_vector = collision.get_remainder().normalized() * pushing_strength * delta
	
	global_position += push_vector

func die():
	music.stop()
	game_over.play()
	you_died.show()
	AudioServer.set_bus_effect_enabled(0, 0, true)
	get_tree().paused = true
	
	#focusbutton.grab_focus()
	#main_node.reset()
	xp_bar.value = 0
	
func get_slash_curve(x):
	# https://www.desmos.com/calculator/zh8hnxofkx -- cosine based
	var a = 4.0 # { a > 2, a%2 == 0 }
	var y = (1 - cos(a*PI*x)) / 2
	if x > 1/a and x < 1-1/a: y = 1.0
	return y
	
func update_animation_parameters():
	var speed_percent = velocity.length() * 2 / speed
	var slash_speed = 1
	var slash_progress = minf(Sword.slash_progress*slash_speed, 1)
	var slash_duration = Sword.slash_duration
	var slash_blend = get_slash_curve(slash_progress)
	animation_tree.set("parameters/Tree/BlendMove/blend_amount", speed_percent)
	animation_tree.set("parameters/Tree/BlendSlash/blend_amount", slash_blend)
	animation_tree.set("parameters/Tree/BlendWalkSlash/blend_amount", slash_blend * speed_percent)
	#animation_tree.set("parameters/Tree/Idle/time", x)
	animation_tree.set("parameters/Tree/Slash/time", slash_progress * slash_duration)
	#animation_tree.set("parameters/Tree/WalkHold/time", x)
	animation_tree.set("parameters/Tree/WalkSlash/time", slash_progress * slash_duration)
	animation_tree.set("parameters/Tree/WalkSpeed/scale", velocity.length() / 12)
	
func position_healthbar():
	# healthbar should be a ring on the floor or slightly off the floor like KLee said
	HeroHealth.position = Cam.unproject_position(global_position)
	HeroHealth.position.x -= HeroHealth.size.x / 2
	HeroHealth.position.y += HeroHealth.size.y
	
	
