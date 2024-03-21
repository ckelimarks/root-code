extends Area3D

# ATTRIBUTES
var recoil = Vector3.ZERO
var touched = false

# NODES AND SCENES
@onready var GemSprite = $GemSprite
@onready var FocusButton = get_node("/root/Main/UICanvas/MarginContainer/VBoxContainer/Button1")
@onready var XpBar = get_node("/root/Main/UICanvas/XpBar")
var AudioSamples := [
	preload("res://assets/sounds/gemsounds/v2/gemsound1.mp3"),
	preload("res://assets/sounds/gemsounds/v2/gemsound2.mp3"),
	preload("res://assets/sounds/gemsounds/v2/gemsound3.mp3"),
	preload("res://assets/sounds/gemsounds/v2/gemsound4.mp3"),
	# ... add more audio samples as needed
]

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body == Hero:
		# recoil is positive to fly away, negative to come back 
		# so don't capture the gem until it has a chance to go away and come back
		
		if touched and recoil < 0: 
			gem_captured()
			return
			
		recoil = 80
		touched = true

		var random_note_index = randi() % AudioSamples.size()
		$AudioStreamPlayer.set_stream(AudioSamples[random_note_index])
		$AudioStreamPlayer.play()
		$AudioStreamPlayer.connect("finished", Callable(self, "_on_audio_finished"))
		Hero.exp += 1
		UI.XpBar.value = Hero.exp
		
	if Hero.exp >= Hero.upgrade_threshold:
		Hero.upgrade_threshold += 5
		Hero.exp = 0
		UI.XpBar.max_value = Hero.upgrade_threshold
		UI.XpBar.value = Hero.exp
		
		get_tree().paused = true
		UI.UpgradeModal.show()
		Hero.current_level += 1
		UI.Level.text = str(Hero.current_level)
		print("Current level:", Hero.current_level)
		
		#AudioServer.add_bus_effect(1, AudioEffectLowPassFilter.new(), 0)
		#AudioServer.cutoff_hz = 400.0
		#AudioServer.set_bus_effect_enabled(1, 1, enable)
		AudioServer.set_bus_effect_enabled(SoundManager.BUS_MASTER, 0, true)
		
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
		recoil -= 256 * delta
		
