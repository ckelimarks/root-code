extends Node3D

# ATTRIBUTES
var march_db_target = -100
var BUS_MASTER = 0
var BUS_MUSIC  = 1
var BUS_SFX    = 2

# SFX
#@onready var SFX             = $SFX
@onready var EmpSound        = $SFX/Emp
@onready var KillSound       = $SFX/Kill
@onready var SlashSound      = $SFX/Slash
@onready var MarchSound      = $SFX/Marching
@onready var StrikeSound     = $SFX/MetalStrike
@onready var ImpactSound     = $SFX/ImpactSound
@onready var GameOverSound   = $SFX/GameOver

# MUSIC
@onready var AtmosphereMusic = $Music/AtmosphereMusic

# Called when the node enters the scene tree for the first time.
func _ready():
	await Mainframe.intro("SoundManager")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	SoundManager.MarchSound.volume_db *= 0.9
	SoundManager.MarchSound.volume_db += 0.1 * SoundManager.march_db_target
