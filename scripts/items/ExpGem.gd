extends Area3D

# ATTRIBUTES
var recoil = Vector3.ZERO
var touched = false
var upgrade_threshold = 10
var current_level = 0

# NODES AND SCENES
@onready var GemSprite = $GemSprite
@onready var FocusButton = get_node("/root/Main/UICanvas/MarginContainer/VBoxContainer/Button1")
@onready var XpBar = get_node("/root/Main/UICanvas/XpBar")
@onready var LevelText = get_node("/root/Main/UICanvas/Level")
@onready var LevelUp = get_node("/root/Main/UICanvas/UpgradeModal")
var AudioSamples := [
	preload("res://sounds/gemsounds/v2/gemsound1.mp3"),
	preload("res://sounds/gemsounds/v2/gemsound2.mp3"),
	preload("res://sounds/gemsounds/v2/gemsound3.mp3"),
	preload("res://sounds/gemsounds/v2/gemsound4.mp3"),
	# ... add more audio samples as needed
]

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	if upgrade_threshold == 10:
		current_level += 1
		LevelText.text = str(current_level)
		print("Current level:", current_level)

func _on_body_entered(body):
	if body == Hero:
		if touched:
			gem_captured()
			return
			
		recoil = 128
		touched = true

		var random_note_index = randi() % AudioSamples.size()
		$AudioStreamPlayer.set_stream(AudioSamples[random_note_index])
		$AudioStreamPlayer.play()
		$AudioStreamPlayer.connect("finished", Callable(self, "_on_audio_finished"))
		XpBar.value = XpBar.value + 1
		

	if XpBar.value == upgrade_threshold:
		get_tree().paused = true
		LevelUp.show()
		
		
		#AudioServer.add_bus_effect(1, AudioEffectLowPassFilter.new(), 0)
		#AudioServer.cutoff_hz = 400.0
		#AudioServer.set_bus_effect_enabled(1, 1, enable)
		AudioServer.set_bus_effect_enabled(0, 0, true)
		XpBar.value = 0
#		Hero.HP = 100
#		Hero.healthbar_node.value = HP / max_HP * 100
		
		
func gem_captured():
	GemSprite.visible = false
	queue_free()
	
func _on_audio_finished():
	pass
	
func _process(delta):
	if touched:
		var start_position = global_position
		var force = (Hero.global_position - global_position).normalized() * recoil * delta
		var new_position = global_position - force
		var sprite_start_position = GemSprite.position  # Save the current position before moving
		var smoothed_position = (start_position + sprite_start_position).lerp(new_position, 0.1)
		global_position = new_position
		global_position.y = 2
		GemSprite.position = smoothed_position - new_position
		recoil -= 10
		
