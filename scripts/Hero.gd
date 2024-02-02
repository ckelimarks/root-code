extends CharacterBody3D

#stats
var HP = 100.0
var max_HP = 100.0
var speed = 16.0
var pushing_strength = 10.0

#movement
var angle = 0.0
var target_angle = 0.0
var throttle = 0.0
var dampening = 0.9

#local nodes
@onready var robot            = $Stan
@onready var animation_player = $Stan/AnimationPlayer
@onready var HeroHealth       = $HealthNode/HeroHealth
@onready var Yantra           = $Yantra
@onready var OrbOrigin        = $OrbOrigin

# autoload these, and put these vars in their top-level scopes
@onready var main_node = get_node("/root/Main")
@onready var xp_bar = get_node("/root/Main/UICanvas/xpBar")
@onready var you_died = get_node("/root/Main/UICanvas/youdied")
@onready var game_over = get_node("/root/Main/GameOverSound")
@onready var focusbutton = get_node("/root/Main/UICanvas/MarginContainer/VBoxContainer/Button1")
@onready var music = get_node("/root/Main/Music")

func _ready():
	#sprite_node.play("idle")
	animation_player.speed_scale = speed / 10.0	
	var robot_collider = robot.get_node("CollisionShape3D")
	$CollisionShape3D.shape.radius = robot_collider.shape.radius
	$CollisionShape3D.shape.height = robot_collider.shape.height	

func _physics_process(delta):
	updateMomentum()
	getUserInteractaction()
	handleMovementAndCollisions(delta)

func updateMomentum():
	throttle *= .1
	velocity *= Vector3(dampening, 0, dampening)
	velocity += Vector3(cos(angle), 0, sin(angle)) * throttle * speed
	
	# Adjust target_angle for shortest rotation path
	target_angle = angle + fposmod(target_angle - angle + PI, 2*PI) - PI
	angle = move_toward(angle, target_angle, PI/12)
	robot.rotation.y = -angle + PI/2
	animation_player.speed_scale = velocity.length() / 10.0

func getUserInteractaction():
	# int(bool) turns true into 1 and false into 0
	var right = int(Input.is_action_pressed('ui_right')) 
	var left = int(Input.is_action_pressed('ui_left'))
	var up = int(Input.is_action_pressed('ui_up'))
	var down = int(Input.is_action_pressed('ui_down'))
	
	animation_player.play("Walk")

	if left+right != 0 || up+down != 0:
		throttle = 1.0
		target_angle = atan2(down - up, right - left)

func handleMovementAndCollisions(delta):
	# First, try to move normally.
	var collision = move_and_collide(velocity * delta)
	var push_vector = Vector3.ZERO
	
	#sprite_node.modulate = Color(1, 1, 1, 1)
	
	if collision:
		var collider = collision.get_collider()
		
		if collider.is_in_group("enemies"):
			$ImpactSound.play()
			HP -= collider.power
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
	
			
