extends CharacterBody3D

var base_power = 10
var power = 0
var slash_progress = 100

func _ready():
	pass

func slash():
	$CollisionShape3D.shape.radius = 25.0
	power = base_power
	#sword_collision.disabled = false
	#else:
	#animation_tree.set("parameters/conditions/slash", false)

func _process(delta):
	slash_progress += delta
	power = 1 / ( pow(5*(slash_progress-.5),2) +1 )
	$CollisionShape3D.shape.radius *= .9
	$CollisionShape3D.shape.radius += 4.0
