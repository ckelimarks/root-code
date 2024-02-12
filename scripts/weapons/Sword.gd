extends CharacterBody3D

# ATTRIBUTES
var slash_progress = 100
var slash_duration = .75 # 0.75 seconds long animation
var base_knock_back = 1
var base_damage = 300
var knock_back = 0
var damage = 0
var power = 0

func _ready():
	SoundManager.SwordSlash.pitch_scale = .6

func slash():
	$SwordSound.pitch_scale = randf_range(.6, 1.0)
	
	# don't allow a new slash in the middle of a swing
	if slash_progress < slash_duration: return
	
	slash_progress = 0
	var slash_sound_delay = 0.15
	await get_tree().create_timer(slash_sound_delay).timeout
	SoundManager.SwordSlash.play()

func _process(delta):
	# redo this, delta should not have a multiplier
	# slash_duration = .75 to match actual animation duration
	# power curve should be transformed cosine wave with restricted domain {0, pi}
	slash_progress += delta
	power = get_power_curve(slash_progress / slash_duration)
	damage = power * base_damage
	knock_back = power * base_knock_back
	$Collider.shape.radius = power * 21.0 + 4.0
	#if slash_progress > slash_duration/2:
	$CSGTorus3D.material.set_shader_parameter("alpha", 1-power)
	
func get_power_curve(x):
	# https://www.desmos.com/calculator/bbsgyy968m -- cosine based
	var y = (1 - cos(4*PI*x)) / 2
	if x < 0.5 or x > 1: y = 0
	return y

