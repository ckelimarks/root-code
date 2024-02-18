extends Node3D

# SFX
@onready var EmpSound        = $SFX/Emp
@onready var KillSound       = $SFX/Kill
@onready var SlashSound      = $SFX/Slash
@onready var MarchSound      = $SFX/Marching
@onready var StrikeSound     = $SFX/MetalStrike
@onready var GameOverSound   = $SFX/GameOver

# MUSIC
@onready var AtmosphereMusic = $Music/AtmosphereMusic

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
