extends Node3D

# NODES AND SCENES
@onready var SwordSlash      = $SFX/SwordSlash
@onready var EmpSound        = $SFX/EmpSound
@onready var EnemyStrike     = $SFX/MetalStrike
@onready var MarchSound      = $SFX/Marching
@onready var GameOverSound   = $SFX/GameOver
@onready var AtmosphereMusic = $Music/AtmosphereMusic

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass