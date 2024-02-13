extends CanvasLayer

# ATTRIBUTES

# NODES AND SCENES
#onready var healthbar_node = Hero.HeroHealth
@onready var MainNode = get_node("/root/Main")
@onready var MusicNode = get_node("/root/Main/Music")

func _ready():
	#get_viewport().connect("size_changed", resize_canvas)
	#resize_canvas()
	pass

func _process(delta):
	pass

#func resize_canvas():
	#var scale_to = 0.75
	##var max_fraction_of_screen = 0.5
	#var view_size = Vector2(get_viewport().size)
	#var target_size = view_size
	#var scale = view_size / size * scale_to
	##var max_scale = Vector2(DisplayServer.screen_get_size())/size
	##scale = min(scale.x, scale.y, min(max_scale.x, max_scale.y) * max_fraction_of_screen)
	#scale = min(scale.x, scale.y)
	#scale = Vector2(scale, scale)
	#position = view_size / 2.0 - (size * scale) / 2.0

func release_modal(node):
	node.hide()
	AudioServer.set_bus_effect_enabled(0, 0, false)
	get_tree().paused = false

func _on_restartbutton_pressed():
	release_modal($YouDied)
	MainNode.reset()
	MusicNode.play()
