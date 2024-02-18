extends Node

# ATTRIBUTES
# local
var cooldown = 3
var heat = 0
# external
@onready var weapons = WeaponManager.weapons

# NODES AND SCENES
var blue_orb_scene = preload("res://scenes/weapons/BlueOrb.tscn")

func _ready():
	pass
	# spawn_orb()

func _physics_process(delta):
	heat -= delta
	if heat < 0:
#	if Input.is_action_pressed('ui_accept'):
		spawn_orb()
		heat = cooldown

func spawn_orb():
	var blue_orb_projectile = blue_orb_scene.instantiate()
	blue_orb_projectile.global_position = Hero.OrbOrigin.global_position 
	add_child(blue_orb_projectile)
	weapons.append(blue_orb_projectile)

	var orb_audio = blue_orb_projectile.get_node("BlueOrbAudio")
	orb_audio.play()
