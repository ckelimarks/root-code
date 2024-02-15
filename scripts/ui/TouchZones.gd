extends Node2D

var anchor = Vector2(0.75, 0.75)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed: send(event.position)
		else: send(Vector2.ZERO)
	elif event is InputEventScreenDrag:
		send(event.position)
		
func send(position):
	if position == Vector2.ZERO:
		Hero.touch.left =   false
		Hero.touch.right =  false
		Hero.touch.up =     false
		Hero.touch.down =   false
		Hero.touch.attack = false
		return

	var view_size = Vector2(get_viewport().size)
	var origin = view_size * anchor
	var direction = position - origin
	var angle = direction.angle() + PI/2
	if angle < 0: angle += 2*PI
	var octant = round(angle / (2*PI) * 8)
	
	Hero.touch.right  = (octant > 0.5) and (octant < 3.5)
	Hero.touch.down   = (octant > 2.5) and (octant < 5.5)
	Hero.touch.left   = (octant > 4.5) and (octant < 7.5)
	Hero.touch.up     = (octant > 6.5) or  (octant < 1.5)
	Hero.touch.attack = true
