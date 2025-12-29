## Autoresizing perspective Camera3D that fits an IK chain with a margin
## Attach this script to a Camera3D node or use it as a custom node in the scene.
class_name CameraAutoFit extends Camera3D

@export var chain_path = NodePath()
@export var margin := 1.2
@export var camera_distance := 10.0
@export var fov_degrees := 45.0
@export var min_distance := 0.5
@export var max_distance := 200.0

var chain: IKChain
var last_joint_count := -1

func _ready():
	projection = PROJECTION_PERSPECTIVE
	fov = fov_degrees

# Remove chain-updated hookups and auto-fit calls - keep helpers if needed
func _on_chain_updated(positions) -> void:
	return

func fit_to_chain() -> void:
	return

func fit_to_positions(positions) -> void:
	return

func _update_center(center_pos: Vector3, dist: float = -1.0):
	return
#	var used_dist: float = dist if dist >= 0.0 else camera_distance
#	var forward: Vector3 = (-global_transform.basis.z).normalized()
#	var cam_pos = center_pos - forward * used_dist
#	global_position = cam_pos
#	look_at(center_pos, Vector3.UP)
#	near = max(0.01, used_dist * 0.01)
#	far = max(used_dist * 3.0, near + 1.0)
