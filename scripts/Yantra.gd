extends Node

var base_power = 1
var power = 1
var cooldown = 2
var heat = 0

func _ready():
	$Collider.disabled = true
	pass # Replace with function body.

func _physics_process(delta):
	#return # use return here to disable for testing
	heat -= delta
	power = base_power * (heat/cooldown)
	#modulate = Color(1, 1, 1, heat)
	if heat < 0:
		heat = cooldown
		$Sprite2D.play()
		$AudioStreamPlayer2D.play()
	elif heat > .8 * cooldown:
		$Collider.disabled = false
	else:
		$Collider.disabled = true
