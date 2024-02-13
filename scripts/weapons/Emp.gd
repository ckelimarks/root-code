extends Node

# ATTRIBUTES
var base_knock_back = 1
var base_damage = 1 # damage dealt at the peak of the power curve
var knock_back = 0
var cooldown = 10 # how long it takes to cool off
var damage = 0
var power = 0
var heat = 0
# move radius/scale to here

# NODES AND SCENES

func _ready():
	connect("body_entered", _on_body_entered)
	$Collider.disabled = true
	$GroundSprite.modulate = Color(1,.5,.3,.8)
	$AirSprite.modulate    = Color(1,.5,.3,.4)

var delay = 0
func _physics_process(delta):
	delay += delta
	if delay < 2: return
	#return # use return here to disable for testing
	heat -= delta
	power = heat/cooldown
	damage = base_damage * power
	knock_back = base_knock_back * power
	if heat < 0:
		heat = cooldown
		$GroundSprite.play()
		$AirSprite.play()
		SoundManager.EmpSound.play()
	elif heat > .8 * cooldown:
		$Collider.disabled = false
	else:
		$Collider.disabled = true

func _on_body_entered(target):
	if target.is_in_group("enemies"):  # Assuming enemies are in a specific group
		# Apply the EMP effect to the enemy
		var gap = target.global_position - Hero.global_position
		var power_falloff = Hero.Emp.scale.x / gap.length()
		#print([gap.length(), power_falloff, Hero.Emp.scale.x])
		target.momentum += (gap).normalized() * (knock_back * power_falloff)
		target.HP -= damage * power_falloff
		if target.HP <= 0:
			target.dead()

		#target.behaviour = "stunned":
		#target.speed *= .5
