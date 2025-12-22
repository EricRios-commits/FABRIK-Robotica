## Visualizes the IK chain (Single Responsibility - visualization only)
## Observer Pattern - observes chain updates
class_name ChainVisualizer extends Node3D

@export var joint_color: Color = Color.RED
@export var segment_color: Color = Color.WHITE
@export var joint_radius: float = 0.1
@export var segment_thickness: float = 0.05
@export var show_joint_spheres: bool = true
@export var show_segments: bool = true

var chain: IKChain
var joint_meshes: Array[MeshInstance3D] = []
var segment_meshes: Array[MeshInstance3D] = []

func _ready() -> void:
	print("ready called")
	chain = get_node_or_null("../IKChain")
	if chain:
		chain.chain_updated.connect(_on_chain_updated)
		create_visualization()
	else:
		push_error("ChainVisualizer: IKChain node not found in parent.")

## Creates initial visualization
func create_visualization() -> void:
	print("create_visualization called")
	clear_visualization()
	if not chain or chain.joints.is_empty():
		print("No chain or joints to visualize")
		return
	print("visualizing chain with " + str(chain.joints.size()) + " joints")	
	if show_joint_spheres:
		for i in range(chain.joints.size()):
			var mesh_instance: MeshInstance3D = MeshInstance3D.new()
			var sphere_mesh: SphereMesh = SphereMesh.new()
			sphere_mesh.radius = joint_radius
			sphere_mesh.height = joint_radius * 2
			var material: StandardMaterial3D = StandardMaterial3D.new()
			material.albedo_color = joint_color
			sphere_mesh.material = material
			mesh_instance.mesh = sphere_mesh
			mesh_instance.name = "JointSphere_" + str(i)
			add_child(mesh_instance)
			joint_meshes.append(mesh_instance)
	if show_segments:
		for i in range(chain.joints.size() - 1):
			var mesh_instance: MeshInstance3D = MeshInstance3D.new()
			mesh_instance.name = "Segment_" + str(i)
			add_child(mesh_instance)
			segment_meshes.append(mesh_instance)
	update_visualization()

## Updates visualization to match current chain state
func update_visualization() -> void:
	if not chain or chain.joints.is_empty():
		return
	var positions: Array[Vector3] = chain.get_positions()
	for i in range(min(joint_meshes.size(), positions.size())):
		joint_meshes[i].global_position = positions[i]
	for i in range(min(segment_meshes.size(), positions.size() - 1)):
		var start: Vector3 = positions[i]
		var end: Vector3 = positions[i + 1]
		var mid: Vector3 = (start + end) / 2.0
		var direction: Vector3 = end - start
		var length: float = direction.length()
		var cylinder: CylinderMesh = CylinderMesh.new()
		cylinder.top_radius = segment_thickness
		cylinder.bottom_radius = segment_thickness
		cylinder.height = length
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = segment_color
		cylinder.material = material
		segment_meshes[i].mesh = cylinder
		segment_meshes[i].global_position = mid
		if direction.length() > 0.001:
			segment_meshes[i].look_at(end, Vector3.UP)
			segment_meshes[i].rotate_object_local(Vector3.RIGHT, PI / 2)

## Clears all visualization
func clear_visualization() -> void:
	for mesh in joint_meshes:
		mesh.queue_free()
	for mesh in segment_meshes:
		mesh.queue_free()
	joint_meshes.clear()
	segment_meshes.clear()

func _on_chain_updated(_positions: Array[Vector3]) -> void:
	update_visualization()
