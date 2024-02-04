extends CharacterBody3D
var power = 0
var base_damage = 10
var slash_progress = 100
var knock_back = 10
var base_knock_back = 1
var damage = 0

func _ready():
	pass

func slash():
	if power > .05:
		return
	slash_progress = 0
	await get_tree().create_timer(.2).timeout
	$SwordSound.play()
	#sword_collision.disabled = false
	#else:
	#animation_tree.set("parameters/conditions/slash", false)

func _process(delta):
	slash_progress += delta * 1.6
	power = 1 / ( pow(5*(slash_progress-.8),2) +1 )
	damage = power * base_damage
	knock_back = power * base_knock_back
	$Collider.shape.radius = power * 21.0 + 4.0
