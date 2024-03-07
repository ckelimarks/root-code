extends CanvasLayer

# ATTRIBUTES

# NODES AND SCENES
# local
@onready var XpBar         = $XpBar
@onready var Level         = $Level
@onready var UpgradeModal  = $UpgradeModal
@onready var RestartModal  = $RestartModal
@onready var RestartButton = $RestartModal/VBoxContainer/RestartButton

# remote
@onready var MainNode  = get_node("/root/Main")
@onready var MusicNode = get_node("/root/Main/Music")

func _ready():
	await Mainframe.intro("UI")
	RestartButton.pressed.connect(_on_restartbutton_pressed)

func _process(delta):
	pass

func release_modal(node):
	node.hide()
	AudioServer.set_bus_effect_enabled(0, 0, false)
	get_tree().paused = false

func _on_restartbutton_pressed():
	MainNode.reset()
	MusicNode.play()
	release_modal($RestartModal)
