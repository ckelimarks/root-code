extends CanvasLayer

var upgrades = [
	{
		"image": preload("res://images/UIgraphics/upgradePanel/sword.jpg"),
		"name": "ELECTRIC SWORD",
		"description": "Increases sword damage",
		"target node": ""
	},
	{
		"image": preload("res://images/UIgraphics/upgradePanel/health.jpg"),
		"name": "MAX HP",
		"description": "Increase your max health by 5%",
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
@onready var upgrade_buttons = [
	$UpgradeModal/ButtonsMargin/VBoxContainer/Button1,
	$UpgradeModal/ButtonsMargin/VBoxContainer/Button2,
	$UpgradeModal/ButtonsMargin/VBoxContainer/Button3,
]

func _ready():
	resize_upgrade_modal()	
	shuffle_upgrades()


func shuffle_upgrades():
	var selected_upgrades = upgrades.duplicate()
	randomize()
	selected_upgrades.shuffle()
	for i in len(upgrade_buttons):
		var button = upgrade_buttons[i]
		var upgrade = selected_upgrades[i]
		button.get_node("%Image").texture    = upgrade.image
		button.get_node("%Name").text        = upgrade.name 
		button.get_node("%Description").text = upgrade.description 
		# using this button callback just for testing
		# the callback should be generic and receive a behaviour from the upgrade object
		button.pressed.connect(self._on_health_pressed)

func _process(delta):
	if $UpgradeModal.visible:
		# link this to viewport size change
		resize_upgrade_modal()

func resize_upgrade_modal():
	var scale_to = 0.75
	var view_size = get_viewport().size
	var target_size = Vector2(1200, 800) * scale_to
	var margin = view_size * 0.2
	var available_space = Vector2(view_size) - margin * 2.0
	var scale_x = available_space.x / target_size.x
	var scale_y = available_space.y / target_size.y
	var scale = min(scale_x, scale_y, scale_to)
	$UpgradeModal.scale = Vector2(scale, scale)
	$UpgradeModal.position = view_size / 2.0 - ($UpgradeModal.size * $UpgradeModal.scale) / 2.0

func _on_speed_pressed():
	Hero.speed += int(Hero.speed < 24)
	Hero.animation_player.speed_scale = Hero.speed / 10
	$MarginContainer.hide()
	AudioServer.set_bus_effect_enabled(0, 0, false)
	get_tree().paused = false
	#pass # Replace with function body.

func _on_push_pressed():
	Hero.pushing_strength += int(Hero.pushing_strength < 20)
	$MarginContainer.hide()
	AudioServer.set_bus_effect_enabled(0, 0, false)
	get_tree().paused = false
	
func _on_health_pressed():
	Hero.max_HP += 50
	Hero.HP = min(Hero.HP + 50, Hero.max_HP)
	#Hero.HeroHealth.max_value = Hero.max_HP
	Hero.HeroHealth.value = Hero.HP
	# lets make the hp bar HP instead of % of maxHP
	#$MarginContainer.hide()
	AudioServer.set_bus_effect_enabled(0, 0, false)
	get_tree().paused = false
	shuffle_upgrades()
	pass # Replace with function body.


func _on_restartbutton_pressed():
	$youdied.hide()
	get_tree().paused = false
	AudioServer.set_bus_effect_enabled(0, 0, false)
	main_node.reset()
	music_node.play()
