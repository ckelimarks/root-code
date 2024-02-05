extends CanvasLayer

var upgrades = [
	{
		"image": preload("res://images/UIgraphics/upgradePanel/sword.jpg"),
		"name": "ELECTRIC SWORD",
		"description": "Increase damage",
		"target node": 	""
	},
	{
		"image": preload("res://images/UIgraphics/upgradePanel/health.jpg"),
		"name": "HEALTH",
		"description": "Increase your max health",
		"target node": 	""
	},
	{
		"image": preload("res://images/UIgraphics/upgradePanel/emp.jpg"),
		"name": "EMP",
		"description": "Increase your EMP pulse‘s radius by 2%",
		"target node": 	""
	},
]

#onready var healthbar_node = Hero.HeroHealth
@onready var main_node = get_node("/root/Main")
@onready var music_node = get_node("/root/Main/Music")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var selected_upgrades = upgrades.duplicate()
	randomize()
	selected_upgrades.shuffle()
	$MarginContainer/MarginContainer/VBoxContainer/Button/RichTextLabel.text = selected_upgrades[0].name 
	$MarginContainer/MarginContainer/VBoxContainer/Button2/RichTextLabel.text = selected_upgrades[1].name
	$MarginContainer/MarginContainer/VBoxContainer/Button3/RichTextLabel.text = selected_upgrades[2].name
	
	$MarginContainer/MarginContainer/VBoxContainer/Button/Description.text = selected_upgrades[0].description
	$MarginContainer/MarginContainer/VBoxContainer/Button2/Description.text = selected_upgrades[1].description
	$MarginContainer/MarginContainer/VBoxContainer/Button3/Description.text = selected_upgrades[2].description
	
	$MarginContainer/MarginContainer/VBoxContainer/Button.icon = selected_upgrades[0].image
	$MarginContainer/MarginContainer/VBoxContainer/Button2.icon = selected_upgrades[1].image
	$MarginContainer/MarginContainer/VBoxContainer/Button3.icon = selected_upgrades[2].image
	
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button2_pressed():
	Hero.speed += int(Hero.speed < 24)
	Hero.animation_player.speed_scale = Hero.speed / 10
	$MarginContainer.hide()
	AudioServer.set_bus_effect_enabled(0, 0, false)
	get_tree().paused = false
	#pass # Replace with function body.


func _on_Button1_pressed():
	Hero.pushing_strength += int(Hero.pushing_strength < 20)
	$MarginContainer.hide()
	AudioServer.set_bus_effect_enabled(0, 0, false)
	get_tree().paused = false
	


func _on_Button3_pressed():
	Hero.max_HP += 50
	Hero.HP = min(Hero.HP + 50, Hero.max_HP)
	#Hero.HeroHealth.max_value = Hero.max_HP
	Hero.HeroHealth.value = Hero.HP
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
