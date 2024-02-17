extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", _on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var knock_back = 3.0
var damage = 1.0
func _on_body_entered(target):
	if target == Hero: #!target.is_in_group("enemies"):
		var gap = target.global_position - global_position
		var power_falloff = 1 # / gap.length()
		target.momentum += gap.normalized() * (knock_back * power_falloff) / target.mass
		target.HP -= damage * power_falloff
