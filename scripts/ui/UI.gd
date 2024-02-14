extends CanvasLayer

# ATTRIBUTES

# NODES AND SCENES
@onready var MainNode  = get_node("/root/Main")
@onready var MusicNode = get_node("/root/Main/Music")
var level = 0

func _ready():
	pass

func _process(delta):
	pass

func release_modal(node):
	node.hide()
	AudioServer.set_bus_effect_enabled(0, 0, false)
	get_tree().paused = false

func _on_restartbutton_pressed():
	release_modal($YouDied)
	MainNode.reset()
	MusicNode.play()
