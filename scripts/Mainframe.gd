extends Node

# initial attributes
var saved_attributes = {
	"Hero": {
		"luck": 0,
		"might": 0,
		"speed": 0, 
		"max_HP": 0,
		"defense": 0,
		"health_regen": 0,
		"pushing_strength": 0,
		"gold": 0
	}
}

func _ready():
	load_game()
	get_tree().paused = true
	await Mainframe.intro("MainFrame")
	get_tree().paused = false
	#save_game()

func _process(delta):
	pass

func intro(caller):
	await get_tree().create_timer(1+0*84.0).timeout
	get_node("/root/UI/IntroVideo").visible = false
	get_node("/root/UI/IntroVideo").paused = true
	print(caller, " Ready")

func save_game():
	var saved_game = FileAccess.open("user://root-code.save", FileAccess.WRITE)
	saved_game.store_line(JSON.stringify(saved_attributes))

func load_game():
	if not FileAccess.file_exists("user://root-code.save"): return
	var save_game = FileAccess.open("user://root-code.save", FileAccess.READ)
	var json_string = save_game.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK: print("JSON Parse Error: ", json.get_error_message())
	else: 
		var data = json.get_data()
		if "Hero" in data:
			for key in data["Hero"].keys():
				saved_attributes["Hero"][key] = data["Hero"][key]
	print("Saved Attributes: ", saved_attributes)
