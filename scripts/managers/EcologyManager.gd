extends Node

var columns = []
var column_gap: float

# NODES
@onready var Ground = get_node("/root/Main/Ground")

# SCENES
var Column = preload("res://scenes/ecology/Column.tscn")

func _ready():
	var corner = -Ground.mesh.size.z * sqrt(2) / 4
	var column_count = 4
	column_gap = sqrt(2) * Ground.mesh.size.z/2 / column_count
	var column_height: float
	for c_z in range(column_count):
		for c_x in range(column_count):
			var new_column = Column.instantiate()
			#if !column_height: 
				#column_height = new_column.get_node("Mesh").mesh.height
			new_column.global_position = Vector3(
				column_gap * (c_x-c_z),
				0,#column_height/2, 
				corner + column_gap * (c_x+c_z - 1)
			)
			add_child(new_column)
			columns.append(new_column)

var target = Vector3.ZERO

func _process(delta):
	target = target.lerp(Hero.global_position, delta/2)
	for column in columns:
		var gap = column.global_position - Hero.global_position
		column.global_rotation.y = atan2(-gap.z, gap.x) + PI/4
		var light = column.get_node("%Light")
		if gap.length() < column_gap: #and Hero is SE of the light
			light.look_at(target)
			light.light_energy = min(20, (column_gap/gap.length() - 1) * 20)
			light.shadow_enabled = true
		else:
			light.light_energy = 0
			light.shadow_enabled = false
