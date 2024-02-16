extends Area3D

var avoid = []

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	pass # Replace with function body.

func _on_body_entered(target):
	avoid.append(target)

func _on_body_exited(target):
	avoid.erase(target)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for target in avoid:
		if (!target): 
			avoid.erase(target)
			continue
		var gap = (global_position - target.global_position) / 10
		if "momentum" in target: target.momentum -= gap / target.mass * delta
