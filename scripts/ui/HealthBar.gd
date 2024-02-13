extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Red.size.x = Hero.HP / Hero.max_HP * 100
	#$Red.color = Color(1 - Hero.HP / 300.0, Hero.HP / 300.0, 0, 1)
	position = Cam.unproject_position(Hero.global_position)
