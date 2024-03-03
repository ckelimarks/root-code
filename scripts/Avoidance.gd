extends Area3D

var avoid = []
var SelfRobot: CharacterBody3D
var SelfEnemy: CharacterBody3D
var is_hero = false

func _ready():
	SelfRobot = get_parent()
	SelfEnemy = SelfRobot.get_parent()
	if SelfEnemy == Hero: 
		is_hero = true
		return
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(target):
	#if avoid.size() > 5: return 
	avoid.append(target)

func _on_body_exited(target):
	avoid.erase(target)

func _process(delta):
	if is_hero: return
	
	if SelfEnemy.behaviour == "guard" or SelfEnemy.behaviour == "march":
		$AvoidanceShape.shape.radius = 3
		
	for target in avoid:
		if (!target): 
			avoid.erase(target)
			continue
		# if both target and SelfEnemy are Guards, then return
		if SelfEnemy.behaviour == "guard" and target.behaviour == "guard": return
		var gap = (global_position - target.global_position) / 10
		var affinity = -1
		if "swarm_id" in target and "swarm_id" in SelfEnemy:
			if target.swarm_id == SelfEnemy.swarm_id: 
				if gap.length() > .5: affinity = 1 # should be 0.5 * dune drone scale
		if "momentum" in target:
			target.momentum += gap / target.mass * delta * affinity
