extends Node
#
## Preload the ruin scenes for later instantiation
#var ruin_scenes = [
#	preload("res://scenes/ruins/ruins005.tscn"),
#	preload("res://scenes/ruins/ruins006.tscn"),
#	preload("res://scenes/ruins/ruins007.tscn"),
#	preload("res://scenes/ruins/ruins008.tscn"),
#	preload("res://scenes/ruins/ruins009.tscn"),
#	preload("res://scenes/ruins/ruins010.tscn"),
#	#preload("res://scenes/ruins/ruins011.tscn"),
#	preload("res://scenes/ruins/ruins012.tscn"),
#	#preload("res://scenes/ruins/ruins013.tscn"),
#	preload("res://scenes/ruins/ruins014.tscn"),
#	#preload("res://scenes/ruins/ruins015.tscn"),
#	preload("res://scenes/ruins/ruins016.tscn"),
#	preload("res://scenes/ruins/ruins017.tscn"),
#	#preload("res://scenes/ruins/ruins018.tscn")
#]
#
## Array to store ruin objects
#var ruins = []
#
#func _ready():
#	# Create 1000 ruin objects with random positions and types
#	for r in range(0):
#		var ruin_object = {
#			"position": Vector3(rand_range(-10000, 10000), 0, rand_range(-10000, 10000)),
#			"type": randi() % ruin_scenes.size(),
#			"active": false,
#			"rect": Rect2()
#		}
#		# Define the bounding rect for each ruin based on its position
#		ruin_object.rect = Rect2(ruin_object.position, Vector2(200, 200))
#		ruins.append(ruin_object)
#
#func _process(delta):
##	# Define the maximum view rectangle considering the camera's position
##	var view_size = get_viewport_rect().size
##	var view_rect_max = Rect2(Cam.global_position - view_size, view_size * Vector2(3, 3))
##
##	# Check each ruin to see if it's within the view rectangle
##	for ruin in ruins:
##		var ruin_visible = view_rect_max.intersects(ruin.rect)
##
##		# If the ruin is now visible and not already active, activate and instance it
##		if ruin_visible and not ruin.active:
##			ruin.active = true
##			ruin.instance = ruin_scenes[ruin.type].instance()
##			ruin.instance.global_position = ruin.position
##			ruin.instance.add_to_group("ruins")
##			add_child(ruin.instance)
##		# If the ruin is no longer visible and is active, deactivate and free it
##		elif not ruin_visible and ruin.active:
##			ruin.active = false
##			ruin.instance.queue_free()
##
##		# Adjust the z_index of active ruins based on their y position relative to the camera
##		if ruin_visible and ruin.active:
##			ruin.instance.z_index = int(ruin.instance.global_position.y - Cam.global_position.y)
#	pass
