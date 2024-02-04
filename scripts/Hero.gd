extends CharacterBody3D

var attributes = {
	"speed": 16, 
	"defense": 0,
	"max_HP": 100,
	"health_regen": 10,
	"luck": 5
}
#stats
var HP = 100.0
var max_HP = 100.0
var speed = 16.0
var pushing_strength = 10.0
var health_regen = .5
var luck = 1 

#movement
var angle = 0.0
var target_angle = 0.0
var throttle = 0.0
var dampening = 0.9
var idle = true

#local nodes
@onready var robot            = $Stan
@onready var animation_player = $Stan/AnimationPlayer
@onready var HeroHealth       = $HealthNode/HeroHealth
@onready var Yantra           = $Yantra
@onready var OrbOrigin        = $OrbOrigin
@onready var sword_collision  = $Stan/RobotArmature/Skeleton3D/BoneAttachment3D/Sword/CollisionShape3D
@onready var animation_tree   = $Stan/AnimationTree

# autoload these, and put these vars in their top-level scopes
@onready var main_node = get_node("/root/Main")
@onready var xp_bar = get_node("/root/Main/UICanvas/xpBar")
@onready var you_died = get_node("/root/Main/UICanvas/youdied")
@onready var game_over = get_node("/root/Main/GameOverSound")
@onready var focusbutton = get_node("/root/Main/UICanvas/MarginContainer/VBoxContainer/Button1")
@onready var music = get_node("/root/Main/Music")

var Sword: CharacterBody3D  

func _ready():
	animation_tree.active = true
	
	#animation_player.speed_scale = speed / 10.0
	#animation_tree.set("parameters/conditions/is_moving", true)
	#animation_tree.set("parameters/conditions/idle", false)
	
	var robot_collider = robot.get_node("Collider")
	$Collider.set_shape(robot_collider.shape)
	$Collider.position = robot_collider.position
	$Collider.rotation = robot_collider.rotation
	Sword = robot.get_node("%Sword")

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
	target_angle = angle + fposmod(target_angle - angle + PI, 2*PI) - PI
	angle = move_toward(angle, target_angle, PI/12)
	robot.rotation.y = -angle + PI/2
	#animation_player.speed_scale = velocity.length() / 10.0

var previous_horizontal_direction = 0
var previous_vertical_direction = 0
func getUserInteraction():
	idle = true
	
	# int(bool) turns true into 1 and false into 0
	var right = int(Input.is_action_pressed('ui_right'))
	var left = int(Input.is_action_pressed('ui_left'))
	var up = int(Input.is_action_pressed('ui_up'))
	var down = int(Input.is_action_pressed('ui_down'))
	#InputEventScreenTouch.
	animation_player.play("Walk")
	
	var x = right - left
	var y = down - up
	if x or y:
		idle = false

		var bias = 0
		if x:
			bias = .1 * previous_vertical_direction * sign(x)
			previous_horizontal_direction = x

		if y:
			bias = .1 * previous_horizontal_direction * sign(-y)
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
	
	focusbutton.grab_focus()
	#main_node.reset()
	xp_bar.value = 0
	
func update_animation_parameters():
	var init_sword_slash = Input.is_action_just_pressed("attack")
	var started_walking_while_slashing = !idle and Sword.power > .5
	#print([idle, Sword.power, Sword.base_power/2, started_walking_while_slashing])
	if idle:
		animation_tree.set("parameters/conditions/idle", true)
		animation_tree.set("parameters/conditions/is_moving", false)
		if init_sword_slash:
			animation_tree.set("parameters/conditions/slash", true)
	else:
		animation_tree.set("parameters/conditions/idle", false)
		animation_tree.set("parameters/conditions/is_moving", true)
		if init_sword_slash or started_walking_while_slashing:
			animation_tree.set("parameters/conditions/slash_walk", true)

	if init_sword_slash:
		animation_tree.set("parameters/TimeScale/scale", 5.0)
		Sword.slash()
	elif !started_walking_while_slashing:
		animation_tree.set("parameters/conditions/slash", false)
		animation_tree.set("parameters/conditions/slash_walk", false)
		
func position_healthbar():
	HeroHealth.position = Cam.unproject_position(global_position)
	HeroHealth.position.x -= HeroHealth.size.x / 2
	
	
