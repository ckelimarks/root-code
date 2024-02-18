extends Node3D

var heat = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	$ExplosionSprite.play("explosion")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	heat -= delta
	$Light.light_energy = get_heat_curve((1-heat)*2) * 10
	if heat<0: self.queue_free()
	
func get_heat_curve(x):
	#https://www.desmos.com/calculator/6ng9humx7q
	var y = 1 - cos(pow(x, .5) * 2*PI)
	if x < 0 or x > 1: y = 0
	return y
