extends CharacterBody3D

var base_power = 10
var power = 0
var slash_progress = 100

func _ready():
	pass

func slash():
	slash_progress = 0
	#sword_collision.disabled = false
	#else:
	#animation_tree.set("parameters/conditions/slash", false)

func _process(delta):
	slash_progress += delta * 1.6
	power = base_power / ( pow(5*(slash_progress-.5),2) +1 )
	print([slash_progress, power])
	$Collider.shape.radius = power/base_power * 21.0 + 4.0
