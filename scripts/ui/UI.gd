extends CanvasLayer

# ATTRIBUTES
var upgrades = [
	{
		"image": preload("res://images/uigraphics/upgradePanel/sword.jpg"),
		"name": "ELECTRIC SWORD",
		"description": "Increases sword damage",
		"callback": upgrade_sword
	},
	{
		"image": preload("res://images/uigraphics/upgradePanel/health.jpg"),
		"name": "MAX HP",
		"description": "Increase your max health by 5%",
		"callback": upgrade_hp
	},
	{
		"image": preload("res://images/uigraphics/upgradePanel/emp.jpg"),
		"name": "EMP",
		"description": "Increase your EMP pulse‘s radius by 2%",
		"callback": upgrade_emp
	},
]

# NODES AND SCENES
#onready var healthbar_node = Hero.HeroHealth
@onready var MainNode = get_node("/root/Main")
@onready var MusicNode = get_node("/root/Main/Music")
@onready var UpgradeButtons = [
	$UpgradeModal/ButtonsMargin/VBoxContainer/Button1,
	$UpgradeModal/ButtonsMargin/VBoxContainer/Button2,
	$UpgradeModal/ButtonsMargin/VBoxContainer/Button3,
]

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
		button.get_node("%Description").text = upgrade.description 
		button.pressed.connect(upgrade.callback)

func resize_upgrade_modal():
	var scale_to = 0.75
	#var max_fraction_of_screen = 0.5
	var view_size = Vector2(get_viewport().size)
	var target_size = view_size
	var scale = view_size / $UpgradeModal.size * scale_to
	#var max_scale = Vector2(DisplayServer.screen_get_size())/$UpgradeModal.size
	#scale = min(scale.x, scale.y, min(max_scale.x, max_scale.y) * max_fraction_of_screen)
	scale = min(scale.x, scale.y)
	$UpgradeModal.scale = Vector2(scale, scale)
	$UpgradeModal.position = view_size / 2.0 - ($UpgradeModal.size * $UpgradeModal.scale) / 2.0

func release_modal(node):
	node.hide()
	AudioServer.set_bus_effect_enabled(0, 0, false)
	get_tree().paused = false
	shuffle_upgrades() # belongs before showing upgrade modal, not here

func upgrade_sword():
	# we can implement a schedule here
	Hero.Sword.base_damage += 1
	release_modal($UpgradeModal)

func upgrade_emp():
	# we can implement a schedule here
	Hero.Emp.base_damage += 1
	release_modal($UpgradeModal)
	
func upgrade_hp():
	Hero.max_HP += 50
	Hero.HP = min(Hero.HP + 50, Hero.max_HP)
	Hero.HeroHealth.value = Hero.HP
	release_modal($UpgradeModal)

func upgrade_speed():
	Hero.speed += 1
	release_modal($UpgradeModal)

func upgrade_pushing_strength():
	Hero.pushing_strength += 1
	release_modal($UpgradeModal)

func _on_restartbutton_pressed():
	release_modal($youdied)
	MainNode.reset()
	MusicNode.play()
