extends Node

var weapons = []
#var blue_orb_weapon = [Hero.BlueOrb]
@onready var BlueOrbEmitter = $BlueOrbEmitter

func _ready():
	weapons.append(Hero.Yantra)
	weapons.append(Hero.sword)
	pass # Replace with function body.

#func _process(delta):
#	pass
