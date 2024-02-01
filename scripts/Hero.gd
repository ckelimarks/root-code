extends CharacterBody3D

var speed = 16.0
var dampening = .9
var pushing_strength = 10.0
var HP = 100.0
var max_HP = 100.0
var target_direction = Vector3.ZERO
var direction = Vector3.ZERO

@onready var smooth_node = $PositionSmoother
@onready var sprite_node = $PositionSmoother/Stan
@onready var animation_player = $PositionSmoother/Stan/AnimationPlayer
@onready var Yantra = $PositionSmoother/Yantra
@onready var OrbOrigin = $PositionSmoother/OrbOrigin
@onready var HeroHealth = $PositionSmoother/HealthNode/HeroHealth

@onready var main_node = get_node("/root/Main")
@onready var xp_bar = get_node("/root/Main/UICanvas/xpBar")
@onready var you_died = get_node("/root/Main/UICanvas/youdied")
@onready var game_over = get_node("/root/Main/GameOverSound")
@onready var music = get_node("/root/Main/Music")
@onready var focusbutton = get_node("/root/Main/UICanvas/MarginContainer/VBoxContainer/Button1")
@onready var stan = $PositionSmoother/Stan
#@onready var stan_collision_shape = $PositionSmoother/Stan/CollisionShape3D
#onready var walking_sound =

var sprite_offset = Vector3()

func _ready():
	
	sprite_offset = smooth_node.position
	#sprite_node.play("idle")
	animation_player.speed_scale = speed / 10.0	
	var stan_collider = stan.get_node("CollisionShape3D")
	$CollisionShape3D.shape.radius = stan_collider.shape.radius
	$CollisionShape3D.shape.height = stan_collider.shape.height
	

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var start_position = global_position  # Save the current position before moving
	var sprite_start_position = smooth_node.position

	velocity *= Vector3(dampening, 0, dampening)
	animation_player.speed_scale = velocity.length() / 10.0	
	
	# Get user interactioin
	interact()
	
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
				music.stop()
				game_over.play()
				you_died.show()
				AudioServer.set_bus_effect_enabled(0, 0, true)
				get_tree().paused = true
				
				focusbutton.grab_focus()
				#main_node.reset()
				xp_bar.value = 0
				
				return
			
		# Attempt to push the collider by manually adjusting the hero's global_position
		push_vector = collision.get_remainder().normalized() * pushing_strength * delta
	
	var new_position = global_position + push_vector
	var smoothed_position = (start_position + sprite_start_position).lerp(new_position + sprite_offset, 0.3)
	global_position = global_position + (new_position - global_position) 
	smooth_node.position = smoothed_position - new_position

func interact():
	# int(bool) turns true into 1 and false into 0
	var right = int(Input.is_action_pressed('ui_right')) 
	var left = int(Input.is_action_pressed('ui_left'))
	var up = int(Input.is_action_pressed('ui_up'))
	var down = int(Input.is_action_pressed('ui_down'))
	
	# left makes x = -1, right makes x = 1
	# up makes z = -1, down makes z = 1
	target_direction = Vector3(right - left, 0, down - up).normalized()
	direction = direction.lerp(target_direction, .3)
	if direction != Vector3.ZERO:
		# atan2 takes z / x (rise over run) and returns an angle
		sprite_node.rotation.y = atan2(-direction.z, direction.x) + PI/2
		animation_player.play("Walk")
		velocity = direction * speed
		
