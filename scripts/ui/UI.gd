extends CanvasLayer

# ATTRIBUTES

# NODES AND SCENES
# local
@onready var XpBar        = $XpBar
@onready var Level        = $Level
@onready var UpgradeModal = $UpgradeModal
@onready var YouDiedModal = $YouDiedModal
# remote
@onready var MainNode  = get_node("/root/Main")
@onready var MusicNode = get_node("/root/Main/Music")

func _ready():
	$YouDiedModal/VBoxContainer/RestartButton.pressed.connect(_on_restartbutton_pressed)
	pass

func _process(delta):
	pass

func release_modal(node):
	node.hide()
	AudioServer.set_bus_effect_enabled(0, 0, false)
	get_tree().paused = false

func _on_restartbutton_pressed():
	print(-1)
	MainNode.reset()
	MusicNode.play()
	release_modal($YouDiedModal)
