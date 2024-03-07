extends Node

# ATTRIBUTES
var weapons = []

# NODES AND SCENES
@onready var BlueOrbEmitter = $BlueOrbEmitter

func _ready():
	await Mainframe.intro("WeaponManager")
	weapons.append(Hero.Emp)
	#weapons.append(Hero.Sword)

#func _process(delta):
#	pass
