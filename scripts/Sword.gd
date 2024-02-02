extends CharacterBody3D

var base_power = 10
var power = 0

func _ready():
	pass

func slash():
	$CollisionShape3D.shape.radius = 25.0
	power = base_power
	#sword_collision.disabled = false
	#else:
	#animation_tree.set("parameters/conditions/slash", false)

func _process(delta):
	power *= .9
	$CollisionShape3D.shape.radius *= .9
	$CollisionShape3D.shape.radius += 4.0
