## Autoresizing perspective Camera3D that fits an IK chain with a margin
## Attach this script to a Camera3D node or use it as a custom node in the scene.
class_name CameraAutoFit extends Camera3D

@export var chain_path = NodePath()
@export var margin = 1.2
@export var camera_distance = 10.0
@export var fov_degrees = 45.0
@export var min_distance = 0.5
@export var max_distance = 200.0

var chain: IKChain
var last_joint_count := -1

func _ready():
	projection = PROJECTION_PERSPECTIVE
	fov = fov_degrees
	if chain:
		if chain.has_signal("chain_updated"):
			chain.chain_updated.connect(_on_chain_updated)
			var positions := chain.get_positions()
			if len(positions) > 0:
				last_joint_count = len(positions)
				fit_to_positions(positions)

	else:
		push_warning("CameraAutoFit: Could not find IKChain node. Set 'chain_path' in the inspector.")

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
	fit_to_positions(chain.get_positions())

func fit_to_positions(positions):
	if not positions or len(positions) == 0:
		return
	var center = Vector3()
	for p in positions:
		center += p
	center /= float(len(positions))
	var max_dx = 0.0
	var max_dy = 0.0
	for p in positions:
		var dx = abs(p.x - center.x)
		var dy = abs(p.y - center.y)
		if dx > max_dx:
			max_dx = dx
		if dy > max_dy:
			max_dy = dy
	if max_dx <= 0.0 and max_dy <= 0.0:
		max_dx = 0.1
		max_dy = 0.1
	var half_width = max_dx * margin
	var half_height = max_dy * margin
	var fov_rad = deg_to_rad(fov_degrees)
	var tan_half = tan(fov_rad * 0.5)
	var vp_size = Vector2(1, 1)
	if get_viewport():
		vp_size = get_viewport().get_visible_rect().size
	var aspect = vp_size.x / vp_size.y if vp_size.y != 0 else 1.0
	var distance_v = half_height / tan_half if tan_half > 0 else camera_distance
	var distance_h = half_width / (tan_half * aspect) if tan_half > 0 and aspect > 0 else camera_distance
	var required_distance = max(distance_v, distance_h, camera_distance)
	required_distance = clamp(required_distance, min_distance, max_distance)
	fov = fov_degrees
	_update_center(center, required_distance)

func _update_center(center_pos: Vector3, dist: float = -1.0):
	var used_dist = dist if dist >= 0.0 else camera_distance
	var forward: Vector3 = (-global_transform.basis.z).normalized()
	var cam_pos = center_pos - forward * used_dist
	global_position = cam_pos
	look_at(center_pos, Vector3.UP)
	near = max(0.01, used_dist * 0.01)
	far = max(used_dist * 3.0, near + 1.0)
