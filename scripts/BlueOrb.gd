extends Area3D

var speed = 200
var dir = Vector3()
var power = 3

@onready var weapons = WeaponManager.weapons

# Called when the node enters the scene tree for the first time.
func _ready():
	dir = Vector3(randf_range(-1,1), 0, randf_range(-1,1)).normalized()
	$Sprite2D.connect("animation_finished", Callable(self, "_on_finished"))
	$Sprite2D.play()

func _on_finished(name: String):
	weapons.erase(self)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += Vector3(speed * dir * delta)


func _on_BlueOrb_body_entered(body):
	if body.name == "EnemyBody":
		#greenslime.dead(50)
		EnemyManager.enemies.erase(self)
	#else:
		#queue_free()
	
