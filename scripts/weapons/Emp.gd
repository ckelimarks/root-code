extends Node

var base_damage = 1
var damage = 0
var power = 1
var cooldown = 2
var heat = 0
var knock_back = 10


func _ready():
	$Collider.disabled = true

func _physics_process(delta):
	#return # use return here to disable for testing
	heat -= delta
	power = heat/cooldown
	damage = base_damage * power
	if heat < 0:
		heat = cooldown
		$Sprite2D.play()
		SoundManager.EmpSound.play()
	elif heat > .8 * cooldown:
		$Collider.disabled = false
	else:
		$Collider.disabled = true
