extends Node

# NODES AND SCENES
var Column = preload("res://scenes/ecology/Column.tscn")

func _ready():
	for c in range(10):
		var new_column = Column.instantiate()
		new_column.global_position = Vector3(-30-50*c, 50, 100*c)
		add_child(new_column)
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
