extends Node

# ATTRIBUTES
var base_knock_back = 1
var base_damage = 1 # damage dealt at the peak of the power curve
var knock_back = 0
var cooldown = 1 # how long it takes to cool off
var damage = 0
var power = 0
var heat = 0

func _ready():
	$Collider.disabled = true

func _physics_process(delta):
	#return # use return here to disable for testing
	heat -= delta
	power = heat/cooldown
	damage = base_damage * power
	knock_back = base_knock_back * power
	if heat < 0:
		heat = cooldown
		$Sprite2D.play()
		SoundManager.EmpSound.play()
	elif heat > .8 * cooldown:
		$Collider.disabled = false
	else:
		$Collider.disabled = true
