extends Node

# ATTRIBUTES
var columns = []
var column_gap: float

# NODES
@onready var Ground = $Bool/Ground
# SCENES
var Column = preload("res://scenes/ecology/Column.tscn")

func _ready():
	await Mainframe.intro("EcologyManager")
	var corner = -Ground.size.z * sqrt(2) / 4
	var column_count = 4
	var column_height: float
	Ground.global_position.y = -Ground.size.y/2
	column_gap = sqrt(2) * Ground.size.z/2 / column_count
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
	target = target.lerp(Cam.target_position, delta/2)
	for column in columns:
		var gap = column.global_position - Cam.target_position
		column.global_rotation.y = atan2(-gap.z, gap.x) + PI/4
		var light = column.get_node("%Light")
		if gap.length() < column_gap:
			light.look_at(target)
			light.light_energy = min(40, (column_gap/gap.length() - 1) * 40)
			light.shadow_enabled = true
			light.visible = true
		else:
			light.visible = false
			light.light_energy = 0
			light.shadow_enabled = false

func altitude_at(position: Vector3):
	position.y = 0
	var rotated_position = Vector2(position.x, position.z).rotated(PI/4)
	var ramp = $Bool/Ramp
	var ramp_edge = 415
	if rotated_position.x < ramp_edge or abs(rotated_position.y) > ramp.size.z/2: 
		return position
	position.y = cos(PI/2-ramp.rotation.z) * (rotated_position.x-ramp_edge)
	return position
