## Main scene controller - orchestrates all components
## Follows Dependency Inversion - depends on abstractions (IKController, visualizers)
extends Node3D

@onready var ik_controller: IKController = $IKController
@onready var chain_visualizer: ChainVisualizer = $ChainVisualizer
@onready var target_visualizer: TargetVisualizer = $TargetVisualizer
@onready var camera: Camera3D = $Camera3D
@onready var control_panel: IKControlPanel = $CanvasLayer/IKControlPanel

var is_dragging_target: bool = false
var drag_plane: Plane = Plane(Vector3.FORWARD, 0)

func _ready():
	setup_scene()
	connect_signals()

func setup_scene():
	if camera:
		camera.position = Vector3(0, 3, 8)
		camera.look_at(Vector3.ZERO, Vector3.UP)
	if target_visualizer and ik_controller:
		var initial_target = Vector3(2, 2, 0)
		target_visualizer.set_target_position(initial_target)

func connect_signals():
	if control_panel:
		control_panel.algorithm_changed.connect(_on_algorithm_changed)
		control_panel.parameters_changed.connect(_on_parameters_changed)
		control_panel.reset_requested.connect(_on_reset_requested)
	if ik_controller:
		ik_controller.solve_completed.connect(_on_solve_completed)

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging_target = event.pressed
	# if event is InputEventMouseMotion and is_dragging_target:
	# 	move_target_with_mouse(event.position)

func move_target_with_mouse(screen_pos: Vector2):
	if not camera or not target_visualizer:
		return
	var from = camera.project_ray_origin(screen_pos)
	var direction = camera.project_ray_normal(screen_pos)
	var intersection = drag_plane.intersects_ray(from, direction)
	if intersection:
		target_visualizer.set_target_position(intersection)

func _on_algorithm_changed(algorithm_name: String):
	if ik_controller:
		ik_controller.set_solver_by_name(algorithm_name)

func _on_parameters_changed(max_iterations: int, tolerance: float):
	if ik_controller:
		ik_controller.configure_solver(max_iterations, tolerance)

func _on_solve_requested():
	if ik_controller:
		ik_controller.solve()

func _on_reset_requested():
	if ik_controller:
		ik_controller.reset_chain()
	if target_visualizer:
		target_visualizer.set_target_position(Vector3(2, 2, 0))

func _on_solve_completed(positions: Array[Vector3], iterations: int, final_error: float):
	if control_panel and ik_controller and ik_controller.solver:
		control_panel.update_stats(iterations, final_error, ik_controller.solver.get_algorithm_name())
