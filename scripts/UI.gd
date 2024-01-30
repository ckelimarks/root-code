extends CanvasLayer

#onready var healthbar_node = Hero.HeroHealth
@onready var main_node = get_node("/root/Main")
@onready var music_node = get_node("/root/Main/Music")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button2_pressed():
	Hero.speed = Hero.speed + 100
	Hero.sprite_node.speed_scale = Hero.speed / 300
	$MarginContainer.hide()
	AudioServer.set_bus_effect_enabled(0, 0, false)
	get_tree().paused = false
	#pass # Replace with function body.


func _on_Button1_pressed():
	Hero.pushing_strength = Hero.pushing_strength + 300
	$MarginContainer.hide()
	AudioServer.set_bus_effect_enabled(0, 0, false)
	get_tree().paused = false
	


func _on_Button3_pressed():
	Hero.max_HP = Hero.max_HP + 50
	Hero.HP = min(Hero.HP + 50, Hero.max_HP)
	# lets make the hp bar HP instead of % of maxHP
	$MarginContainer.hide()
	AudioServer.set_bus_effect_enabled(0, 0, false)
	get_tree().paused = false
	pass # Replace with function body.


func _on_restartbutton_pressed():

	$youdied.hide()
	get_tree().paused = false
	AudioServer.set_bus_effect_enabled(0, 0, false)
	main_node.reset()
	music_node.play()
