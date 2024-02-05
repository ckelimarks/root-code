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
	Hero.max_HP = Mainframe.saved_attributes.Hero.max_HP
	Hero.HP = Hero.max_HP
	Hero.HeroHealth.value = Hero.HP
	Hero.speed = Mainframe.saved_attributes.Hero.speed
	Hero.defense = Mainframe.saved_attributes.Hero.defense
	Hero.luck = Mainframe.saved_attributes.Hero.luck
	Hero.global_position = Vector3.ZERO
	

