extends Node

# initial attributes
var saved_attributes = {
	"Hero": {
		"speed": 0, 
		"defense": 0,
		"max_HP": 0,
		"health_regen": 0,
		"luck": 0
	}
}

func _ready():
	load_game()
	#save_game()

func _process(delta):
	pass

func save_game():
	var save_game = FileAccess.open("user://root-code.save", FileAccess.WRITE)
	save_game.store_line(JSON.stringify(saved_attributes))

func load_game():
	if not FileAccess.file_exists("user://root-code.save"): return
	var save_game = FileAccess.open("user://root-code.save", FileAccess.READ)
	var json_string = save_game.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK: print("JSON Parse Error: ", json.get_error_message())
	else: saved_attributes = json.get_data()
