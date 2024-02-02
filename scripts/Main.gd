extends Node3D

func _ready():
	pass

func reset():
	# unspawn enemies
	for enemy in EnemyManager.enemies:
		enemy.queue_free()
	EnemyManager.enemies = []

	# unspawn weapons
	#for weapon in $WeaponManager.weapons:
	#	weapon.queue_free()
	#$WeaponManager.weapons = []

	# reset/respawn Hero
	Hero.HP = Hero.max_HP
	Hero.HeroHealth.value = 100
	Hero.global_position = Vector3.ZERO
