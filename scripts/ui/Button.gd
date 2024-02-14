extends Button

func _ready():
	pressed.connect(thing)

func thing():
	print(0)
#func _process(delta):
	
#	pass
