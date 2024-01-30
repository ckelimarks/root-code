extends Area

var recoil = Vector3.ZERO
var touched = false
onready var focusbutton = get_node("/root/Main/UICanvas/MarginContainer/VBoxContainer/Button1")

var audio_samples := [
	preload("res://sounds/gemsounds/v2/gemsound1.mp3"),
	preload("res://sounds/gemsounds/v2/gemsound2.mp3"),
	preload("res://sounds/gemsounds/v2/gemsound3.mp3"),
	preload("res://sounds/gemsounds/v2/gemsound4.mp3"),
	# ... add more audio samples as needed
]

onready var xpBar = get_node("/root/Main/UICanvas/xpBar")
onready var levelUp = get_node("/root/Main/UICanvas/MarginContainer")

func _ready():
	connect("body_entered", self, "_on_body_entered")

	
	
func _on_body_entered(body):
	if body == Hero:
		if touched:
			gem_captured()
			return
			
		recoil = 1000
		touched = true

		var random_note_index = randi() % audio_samples.size()
		$AudioStreamPlayer.set_stream(audio_samples[random_note_index])
		$AudioStreamPlayer.play()
		$AudioStreamPlayer.connect("finished", self, "_on_audio_finished")
		xpBar.value = xpBar.value + 1
		
	if xpBar.value == 10:
		
		get_tree().paused = true
		levelUp.show()
		focusbutton.grab_focus()
		
		#AudioServer.add_bus_effect(1, AudioEffectLowPassFilter.new(), 0)
		#AudioServer.cutoff_hz = 400.0
		#AudioServer.set_bus_effect_enabled(1, 1, enable)
		AudioServer.set_bus_effect_enabled(0, 0, true)
		xpBar.value = 0
#		Hero.HP = 100
#		Hero.healthbar_node.value = HP / max_HP * 100
		
		
func gem_captured():
	$Sprite.visible = false
	queue_free()
	
func _on_audio_finished():
	pass
	
func _process(delta):
	if touched:
		var start_position = global_translation
		var force = (Hero.global_translation - global_translation).normalized() * recoil * delta
		var new_position = global_translation - force
		var sprite_start_position = $Sprite.position  # Save the current position before moving
		var smoothed_position = (start_position + sprite_start_position).linear_interpolate(new_position, 0.1)
		global_translation = new_position
		$Sprite.position = smoothed_position - new_position
		recoil -= 10
		
	self.z_index = int(global_translation.y - Cam.global_translation.y)
