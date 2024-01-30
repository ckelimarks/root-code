extends Spatial

var test = 3
var base_navigation_speed = .05
var time = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

func _process(delta):
	time += delta
	var navigation_speed = base_navigation_speed + sin(time * 10) * .05
#	var right = 0
#	var left = 0
#	var up = 0
#	var down = 0
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var up = Input.is_action_pressed('ui_up')
	var down = Input.is_action_pressed('ui_down')
	#var velocity = Vector3.ZERO
	# Get input from the player
	#sprite_node.play("idle")
	#if Input.is_action_pressed('punch'):
		#sprite_node.play("punch")
		#get_tree().paused = true
	#if sprite_node.animation != "dead":	
	
	
#	var direction = Vector3(right - left, 0, down - up).normalized()
#	if direction != Vector3.ZERO:
#		$RobotArmature.translate(direction * navigation_speed)
#		$AnimationPlayer.rotation.y = atan2(direction.z, direction.x)
#		$AnimationPlayer.play("Walk")
	
	



	if right and down:
		print("right and down SE")
		var movement = Vector3(1, 0, 1).normalized() * navigation_speed
		$RobotArmature.translate(movement)
		$AnimationPlayer.play("Walk")
		$RobotArmature.rotation.y = atan2(movement.z, movement.x)
	elif down and left:
		print("down and left SW")
		var movement = Vector3(-1, 0, 1).normalized() * navigation_speed
		$RobotArmature.translate(movement)
		$AnimationPlayer.play("Walk")
		$RobotArmature.rotation.y = atan2(-movement.z, movement.x) + PI / 2
	elif left and up:
		print("left and up NW")
		var movement = Vector3(-1, 0, -1).normalized() * navigation_speed
		$RobotArmature.translate(movement)
		$AnimationPlayer.play("Walk")
		$RobotArmature.rotation.y = PI + PI / 4 
	elif up and right:
		#velocity += Vector3(navigation_speed, 0, -navigation_speed).normalized()
		print("up and right NE")
		var movement = Vector3(1, 0, -1).normalized() * navigation_speed
		$RobotArmature.translate(movement)
		$AnimationPlayer.play("Walk")
		$RobotArmature.rotation.y = atan2(-movement.z, -movement.x)
	elif right:
		$RobotArmature.translation += Vector3(1,0,-1).normalized() * navigation_speed
		$RobotArmature.rotation.y = PI/2
		$AnimationPlayer.play("Walk")
	elif down:
		$RobotArmature.translation += Vector3(1,0,1).normalized() * navigation_speed
		$RobotArmature.rotation.y = 0
		$AnimationPlayer.play("Walk")
	elif left:
		$RobotArmature.translation += Vector3(-1,0,1).normalized() * navigation_speed
		$RobotArmature.rotation.y = -PI/2
		$AnimationPlayer.play("Walk")
	elif up:
		$RobotArmature.translation += Vector3(-1,0,-1).normalized() * navigation_speed
		$RobotArmature.rotation.y = PI
		$AnimationPlayer.play("Run")


		#if velocity.length() > 0 and !$WalkingSound.playing:
			##print("moving")
			#$WalkingSound.play()
		#elif velocity.length() == 0 and $WalkingSound.playing:
			##print("stopped")
			##$WalkingSound.stop()
			#sprite_node.play("idle")
			#$WalkingSound.stop()	#var forward = $Leela.transform.basis.z.normalized() * navigation_speed

	if Input.is_key_pressed(KEY_W):
		$RobotArmature.translation += Vector3(-1,0,-1).normalized() * navigation_speed
		$RobotArmature.rotation.y = PI
		$AnimationPlayer.play("Run")

	if Input.is_key_pressed(KEY_S):
		$RobotArmature.translation += Vector3(1,0,1).normalized() * navigation_speed
		$RobotArmature.rotation.y = 0
		$AnimationPlayer.play("Walk")

	if Input.is_key_pressed(KEY_A):
		$RobotArmature.translation += Vector3(-1,0,1).normalized() * navigation_speed
		$RobotArmature.rotation.y = -PI/2
		$AnimationPlayer.play("Walk")

	if Input.is_key_pressed(KEY_D):
		$RobotArmature.translation += Vector3(1,0,-1).normalized() * navigation_speed
		$RobotArmature.rotation.y = PI/2
		$AnimationPlayer.play("Walk")

