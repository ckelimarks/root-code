extends Node3D

var time = 0

@onready var MusicNode = get_node("/root/Main/Music")

func _ready():
	await Mainframe.intro("RootCode")
	SoundManager.AtmosphereMusic.play()
	SoundManager.MarchSound.pitch_scale = .7
	SoundManager.MarchSound.volume_db = -100
	SoundManager.MarchSound.play()

func _process(delta):
	time += delta #/ (60*5)
	#$Sun.global_rotation.x = -PI/6# + PI/24 * sin(time/10)
	#$Sun.global_rotation.y = time + PI/3

func reset_begin():
	# unspawn enemies
	#for enemy in EnemyManager.enemies:
		#enemy.queue_free()
	#EnemyManager.enemies = []
	EnemyManager.rogue_alert_on = false
	# reset platoon should live in Platoon	EnemyManager.Platoon.exists = false
	#EnemyManager.Platoon.holes = {}
	#EnemyManager.Platoon.occupied = {}
	#EnemyManager.Platoon.members = []


	# unspawn weapons
	Hero.Emp.enabled = false
	#for weapon in $WeaponManager.weapons:
	#	weapon.queue_free()
	#$WeaponManager.weapons = []

	# reset/respawn Hero
	Hero.luck = Hero.min_stats.luck + Mainframe.saved_attributes.Hero.luck
	Hero.speed = Hero.min_stats.speed + Mainframe.saved_attributes.Hero.speed
	Hero.max_HP = Hero.min_stats.max_HP + Mainframe.saved_attributes.Hero.max_HP
	Hero.defense = Hero.min_stats.defense + Mainframe.saved_attributes.Hero.defense
	Hero.health_regen = Hero.min_stats.health_regen + Mainframe.saved_attributes.Hero.health_regen
	Hero.pushing_strength = Hero.min_stats.pushing_strength + Mainframe.saved_attributes.Hero.pushing_strength
	Hero.current_level = 0
	Hero.HP = Hero.max_HP

	Hero.woke             = false
	Hero.target_angle     = PI/2
	Hero.angle            = Hero.target_angle
	Hero.Robot.rotation.y = 0
	Hero.momentum         = Vector3.ZERO
	Hero.global_position  = Vector3.ZERO
	Hero.sleepen()
	
	# return to console
	Console.attach_hero()
	Console.transferred = false
	Console.visible = true

func reset_complete():
	MusicNode.play()
	EnemyManager.Platoon.clear_ranks()
	EnemyManager.Platoon.init_ranks()
