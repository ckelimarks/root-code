extends CharacterBody3D

var speed = 10.0
var pushing_strength = 10.0  # Adjust the pushing effect as needed
var HP = 100.0
var max_HP = 100.0
#var velocity = Vector3.ZERO

@onready var smooth_node = $PositionSmoother
@onready var sprite_node = $PositionSmoother/Stan
@onready var Yantra = $PositionSmoother/Yantra
@onready var OrbOrigin = $PositionSmoother/OrbOrigin
@onready var HeroHealth = $PositionSmoother/HealthNode/HeroHealth

@onready var main_node = get_node("/root/Main")
@onready var xp_bar = get_node("/root/Main/UICanvas/xpBar")
@onready var you_died = get_node("/root/Main/UICanvas/youdied")
@onready var game_over = get_node("/root/Main/GameOverSound")
@onready var music = get_node("/root/Main/Music")
@onready var focusbutton = get_node("/root/Main/UICanvas/MarginContainer/VBoxContainer/Button1")

#onready var walking_sound =

var sprite_offset = Vector3()

func _ready():
	sprite_offset = smooth_node.position
	#sprite_node.play("idle")
	#sprite_node.speed_scale = speed / 300.0

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var start_position = global_position  # Save the current position before moving
	var sprite_start_position = smooth_node.position

	# Move the player
	# First, try to move normally.
	var collision = move_and_collide(velocity.normalized() * speed * delta)
	var push_vector = Vector3.ZERO
	
	#sprite_node.modulate = Color(1, 1, 1, 1)
	
	if collision:
		$ImpactSound.play()
		if collision.collider.is_in_group("enemies"):
			HP -= collision.collider.power
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
		push_vector = collision.remainder.normalized() * pushing_strength * delta
	
	var new_position = global_position + push_vector
	var smoothed_position = (start_position + sprite_start_position).lerp(new_position + sprite_offset, 0.3)
	global_position = global_position + (new_position - global_position) 
	smooth_node.position = smoothed_position - new_position
	
	#self.z_index = int(smoothed_position.y - Cam.global_translation.y)
	
func _on_Stan_animation_finished():
	pass
	#sprite_node.play("idle")
	
