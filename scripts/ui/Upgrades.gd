extends MarginContainer

# ATTRIBUTES
var upgrades = [
	{
		"image": preload("res://images/uigraphics/upgradePanel/sword.jpg"),
		"name": "ELECTRIC SWORD",
		"description": ["Increases sword damage"],
		"callback": upgrade_sword,
		"level": 0
	},
	{
		"image": preload("res://images/uigraphics/upgradePanel/health.jpg"),
		"name": "MAX HP",
		"description": ["Increase your max health by 5%"],
		"callback": upgrade_hp,
		"level": 0
	},
	{
		"image": preload("res://images/uigraphics/upgradePanel/emp.jpg"),
		"name": "EMP",
		"description": [
			"Increase your EMP radius from 70% to 120%",
			"Increase your EMP cool-down from 5 to 3",
			"Increase your EMP damage from 1 to 5",
			"Increase your EMP knock-back from 1 to 3",
			"Increase your EMP damage from 5 to 10",
			"Increase your EMP radius from 120% to 200%",
			"Increase your EMP cool-down from 3 to 2",
			"Increase your EMP damage from 10 to 15",
			"Increase your EMP knock-back from 3 to 5",
			"Increase your EMP damage from 15 to 20",
			"Increase your EMP radius from 200% to 300%",
			"Increase your EMP cool-down from 2 to 1",
			"MAX"
		],
		"callback": upgrade_emp,
		"level": 0
	},
]

# NODES AND SCENES
# local
@onready var UpgradeButtons = [
	$ButtonsMargin/VBoxContainer/Button1,
	$ButtonsMargin/VBoxContainer/Button2,
	$ButtonsMargin/VBoxContainer/Button3,
]
# remote

func _ready():
	get_viewport().connect("size_changed", resize_upgrade_modal)
	resize_upgrade_modal()
	shuffle_upgrades()

func _process(delta):
	pass

func shuffle_upgrades():
	var selected_upgrades = upgrades.duplicate()
	randomize()
	selected_upgrades.shuffle()
	for i in len(UpgradeButtons):
		var button = UpgradeButtons[i]
		var upgrade = selected_upgrades[i]
		button.get_node("%Image").texture    = upgrade.image
		button.get_node("%Name").text        = upgrade.name 
		button.get_node("%Description").text = upgrade.description[min(
			upgrade.description.size() -1, 
			upgrade.level
		)] 
		button.pressed.connect(upgrade.callback.bind(upgrade))

func resize_upgrade_modal():
	var scale_to = 0.75
	#var max_fraction_of_screen = 0.5
	var view_size = Vector2(get_viewport().size)
	var target_size = view_size
	var target_scale = view_size / self.size * scale_to
	#var max_scale = Vector2(DisplayServer.screen_get_size())/self.size
	#target_scale = min(target_scale.x, target_scale.y, min(max_scale.x, max_scale.y) * max_fraction_of_screen)
	target_scale = min(target_scale.x, target_scale.y)
	self.scale = Vector2(target_scale, target_scale)
	self.position = view_size / 2.0 - (self.size * self.scale) / 2.0

func release_modal():
	hide()
	AudioServer.set_bus_effect_enabled(0, 0, false)
	get_tree().paused = false
	shuffle_upgrades() # belongs before showing upgrade modal, not here

func upgrade_sword(upgrade):
	# we can implement a schedule here
	Hero.Sword.base_damage += 1
	release_modal()

func upgrade_emp(upgrade):
	upgrade.level += 1
	if upgrade.level == 1: Hero.Emp.rad = 1.2
	if upgrade.level == 2: Hero.Emp.cooldown = 6
	if upgrade.level == 3: Hero.Emp.base_damage = 5
	if upgrade.level == 4: Hero.Emp.base_knock_back = 3
	if upgrade.level == 5: Hero.Emp.base_damage = 10
	if upgrade.level == 6: Hero.Emp.rad = 2.0
	if upgrade.level == 7: Hero.Emp.cooldown = 3
	if upgrade.level == 8: Hero.Emp.base_damage = 15
	if upgrade.level == 9: Hero.Emp.base_knock_back = 5
	if upgrade.level == 10: Hero.Emp.base_damage = 20
	if upgrade.level == 11: Hero.Emp.rad = 3.0
	if upgrade.level == 12: Hero.Emp.cooldown = 1
	Hero.Emp.heat = 0
	release_modal()
	
func upgrade_hp(upgrade):
	Hero.max_HP += 50
	Hero.HP = min(Hero.HP + 50, Hero.max_HP)
	release_modal()

func upgrade_speed(upgrade):
	Hero.speed += 1
	release_modal()

func upgrade_pushing_strength(push_level):
	Hero.pushing_strength += 1
	release_modal()
