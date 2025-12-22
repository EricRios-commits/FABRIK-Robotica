## Visualizes the IK target (Single Responsibility)
class_name TargetVisualizer extends Node3D

@export var target_color: Color = Color.GREEN
@export var target_size: float = 0.15
@export var show_reach_indicator: bool = true

var mesh_instance: MeshInstance3D
var controller: IKController

func _ready():
	create_target_mesh()
	controller = get_node_or_null("../IKController")

## Creates the target visualization mesh
func create_target_mesh():
	mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = target_size
	sphere_mesh.height = target_size * 2
	var material = StandardMaterial3D.new()
	material.albedo_color = target_color
	material.emission_enabled = true
	material.emission = target_color
	material.emission_energy_multiplier = 0.5
	sphere_mesh.material = material
	mesh_instance.mesh = sphere_mesh
	mesh_instance.name = "TargetMesh"
	add_child(mesh_instance)

## Updates target position
func set_target_position(target: Vector3):
	global_position = target
	if controller:
		controller.set_target(target)

## Updates target color based on reachability
func update_reachability_indicator(is_reachable: bool):
	if not show_reach_indicator or not mesh_instance:
		return
	var material = mesh_instance.mesh.material as StandardMaterial3D
	if is_reachable:
		material.albedo_color = Color.GREEN
		material.emission = Color.GREEN
	else:
		material.albedo_color = Color.ORANGE
		material.emission = Color.ORANGE
