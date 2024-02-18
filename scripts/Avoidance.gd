extends Area3D

var avoid = []
var SelfRobot: CharacterBody3D
var SelfEnemy: CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	SelfRobot = get_parent()
	SelfEnemy = SelfRobot.get_parent()
	if SelfEnemy == Hero: return
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(target):
	#if avoid.size() > 5: return 
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
		var affinity = -1
		if "swarm_id" in target and "swarm_id" in SelfEnemy:
			if target.swarm_id == SelfEnemy.swarm_id: 
				if gap.length() > .5: affinity = 1
		if "momentum" in target:
			target.momentum += gap / target.mass * delta * affinity
