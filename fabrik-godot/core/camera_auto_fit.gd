## Autoresizing orthographic Camera3D that fits an IK chain with a margin
## Attach this script to a Camera3D node or use it as a custom node in the scene.
class_name CameraAutoFit extends Camera3D

@export var chain_path = NodePath()
@export var margin = 1.2
@export var camera_distance = 10.0

var chain = null
var last_joint_count = -1

func _ready():
	projection = PROJECTION_ORTHOGONAL
	if str(chain_path) != "":
		chain = get_node_or_null(chain_path)
	if chain:
		if chain.has_signal("chain_updated"):
			chain.chain_updated.connect(_on_chain_updated)
			if chain.has_method("get_positions"):
				var positions = chain.get_positions()
				if len(positions) > 0:
					last_joint_count = len(positions)
					fit_to_positions(positions)
		else:
			fit_to_chain()
	else:
		push_warning("CameraAutoFit: Could not find IKChain node. Set 'chain_path' in the inspector or name the chain node 'IKChain'.")

func _on_chain_updated(positions):
	if positions and len(positions) > 0:
		_update_center(positions[0])
	var current_count = len(positions) if positions else 0
	if current_count != last_joint_count:
		last_joint_count = current_count
		fit_to_positions(positions)

func fit_to_chain():
	if not chain:
		return
	if chain.has_method("get_positions"):
		fit_to_positions(chain.get_positions())
	else:
		var positions = []
		for child in chain.get_children():
			if typeof(child) == TYPE_OBJECT and child is Node3D:
				positions.append(child.global_position)
		fit_to_positions(positions)

func fit_to_positions(positions):
	if not positions or len(positions) == 0:
		return
	var root = positions[0]
	var max_dx = 0.0
	var max_dy = 0.0
	for p in positions:
		var dx = abs(p.x - root.x)
		var dy = abs(p.y - root.y)
		if dx > max_dx:
			max_dx = dx
		if dy > max_dy:
			max_dy = dy
	var max_extent = max(max_dx, max_dy)
	if max_extent <= 0.0:
		max_extent = 0.1
	var ortho_size = max_extent * margin
	self.size = ortho_size
	_update_center(root)

func _update_center(root_pos):
	var cam_pos = root_pos + Vector3(0, 0, camera_distance)
	global_position = cam_pos
	look_at(root_pos, Vector3.UP)
