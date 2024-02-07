extends Node

var weapons = []
#var blue_orb_weapon = [Hero.BlueOrb]
@onready var BlueOrbEmitter = $BlueOrbEmitter

func _ready():
	weapons.append(Hero.Emp)
	#weapons.append(Hero.Sword)

#func _process(delta):
#	pass
