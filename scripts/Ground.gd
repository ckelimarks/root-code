extends MeshInstance2D
#
#var ground_texture_size = Vector2() # Replace with your ground texture's actual size in pixels
#
#func _ready():
#	update_mesh_size()
#	var ground_texture = preload("res://images/ground/ground.jpg")
#	ground_texture_size = ground_texture.get_size() * Vector2(.75,.75)
#	update_shader_params()
#
#func _process(_delta):
#	update_mesh_size()
#	update_shader_params()
#
#
#func update_mesh_size():
#	var screen_size = get_viewport_rect().size
#	if mesh:
#		mesh.size = screen_size*1.5
#
#func update_shader_params():
#	var camera_pos = Cam.get_camera_screen_center()
#
#	# Adjust the position if the camera has smoothing or drag margins
#	var drag_margin_h = Cam.get_drag_margin(MARGIN_LEFT) + Cam.get_drag_margin(MARGIN_RIGHT)
#	var drag_margin_v = Cam.get_drag_margin(MARGIN_TOP) + Cam.get_drag_margin(MARGIN_BOTTOM)
#	camera_pos += Cam.get_offset() * Vector2(drag_margin_h, drag_margin_v)
#
#	# Update shader parameters
#	material.set_shader_param("camera_pos", camera_pos)
#	material.set_shader_param("texture_size", ground_texture_size)
#	material.set_shader_param("window_size", get_viewport_rect().size)
#
#	#var hero = get_node_or_null("/root/Main/Hero") # Adjust path
#	#if hero:
#	#	var character_pos = hero.global_position
#	#	material.set_shader_param("hero_pos", hero_pos)
