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
var target_movement_enabled: bool = false
var auto_solve_enabled: bool = false

func _ready() -> void:
	setup_scene()
	connect_signals()

func setup_scene() -> void:
	if camera:
		camera.position = Vector3(0, 3, 8)
		camera.look_at(Vector3.ZERO, Vector3.UP)
	if target_visualizer and ik_controller:
		var initial_target: Vector3 = Vector3(2, 2, 0)
		target_visualizer.set_target_position(initial_target)

func connect_signals() -> void:
	if control_panel:
		control_panel.algorithm_changed.connect(_on_algorithm_changed)
		control_panel.parameters_changed.connect(_on_parameters_changed)
		control_panel.reset_requested.connect(_on_reset_requested)
		control_panel.solve_requested.connect(_on_solve_requested)
		control_panel.next_step_requested.connect(_on_next_step_requested)
		control_panel.joint_count_changed.connect(_on_joint_count_changed)
		control_panel.target_movement_toggled.connect(_on_target_movement_toggled)
		control_panel.auto_solve_toggled.connect(_on_auto_solve_toggled)
	if ik_controller:
		ik_controller.solve_completed.connect(_on_solve_completed)
		ik_controller.step_executed.connect(_on_step_executed)

func _input(event: InputEvent) -> void:
	if not target_movement_enabled:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging_target = event.pressed
	if event is InputEventMouseMotion and is_dragging_target:
		move_target_with_mouse(event.position)

func move_target_with_mouse(screen_pos: Vector2) -> void:
	if not camera or not target_visualizer:
		return
	var from: Vector3 = camera.project_ray_origin(screen_pos)
	var direction: Vector3 = camera.project_ray_normal(screen_pos)
	var intersection: Variant = drag_plane.intersects_ray(from, direction)
	if intersection:
		target_visualizer.set_target_position(intersection)

func _on_algorithm_changed(algorithm_name: String) -> void:
	if ik_controller:
		ik_controller.set_solver_by_name(algorithm_name)

func _on_parameters_changed(max_iterations: int, tolerance: float) -> void:
	if ik_controller:
		ik_controller.configure_solver(max_iterations, tolerance)

func _on_solve_requested() -> void:
	if ik_controller:
		ik_controller.set_step_mode(false)
		ik_controller.solve()

func _on_reset_requested() -> void:
	if ik_controller:
		ik_controller.set_step_mode(false)
		ik_controller.reset_chain()

func _on_solve_completed(_positions: Array[Vector3], iterations: int, final_error: float) -> void:
	if control_panel and ik_controller and ik_controller.solver:
		control_panel.update_stats(iterations, final_error, ik_controller.solver.get_algorithm_name())

func _on_next_step_requested() -> void:
	if not ik_controller:
		return
	if not ik_controller.step_mode_enabled:
		ik_controller.set_step_mode(true)
		ik_controller.solve()
	ik_controller.execute_next_step()

func _on_step_executed(step_info: Dictionary) -> void:
	if control_panel:
		control_panel.update_step_info(step_info)

func _on_joint_count_changed(count: int) -> void:
	if ik_controller and ik_controller.chain:
		ik_controller.chain.set_joint_count(count)
		if chain_visualizer:
			chain_visualizer.create_visualization()

func _on_target_movement_toggled(enabled: bool) -> void:
	target_movement_enabled = enabled

func _on_auto_solve_toggled(enabled: bool) -> void:
	auto_solve_enabled = enabled
	if ik_controller:
		ik_controller.auto_solve = enabled
