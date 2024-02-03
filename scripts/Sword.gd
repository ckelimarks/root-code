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
	#slash_elapsed_time_percentage += delta
	#sin(slash_elapsed_time_percentage*PI)
	#1 / ( pow(5*(x-.5),2) +1 )
	$CollisionShape3D.shape.radius *= .9
	$CollisionShape3D.shape.radius += 4.0
