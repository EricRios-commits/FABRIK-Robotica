## Controller that manages IK solving for a chain (Single Responsibility)
## Coordinates between the chain, solver, and visualization
class_name IKController extends Node

## Emitted when solving is complete
signal solve_completed(positions: Array[Vector3], iterations: int, final_error: float)
## Emitted when a step is executed in step mode
signal step_executed(step_info: Dictionary)

@export var auto_solve: bool = false
@export var max_iterations: int = 10
@export var tolerance: float = 0.01

var chain: IKChain
var solver: IKSolver
var target_position: Vector3 = Vector3.ZERO
var is_solving: bool = false
var step_executor: StepExecutor = StepExecutor.new()
var step_mode_enabled: bool = false

func _ready() -> void:
	chain = get_node_or_null("../IKChain")
	set_solver(IKSolverFactory.SolverType.FABRIK)
	step_executor.step_executed.connect(_on_step_executed)
	step_executor.execution_completed.connect(_on_execution_completed)

## Sets the IK solver to use
func set_solver(solver_type: IKSolverFactory.SolverType) -> void:
	solver = IKSolverFactory.create_solver(solver_type)
	solver.max_iterations = max_iterations
	solver.tolerance = tolerance
	solver.enable_debug = true
	if step_mode_enabled:
		solver.step_executor = step_executor

## Sets the solver by name
func set_solver_by_name(solver_name: String) -> void:
	solver = IKSolverFactory.create_solver_by_name(solver_name)
	solver.max_iterations = max_iterations
	solver.tolerance = tolerance
	solver.enable_debug = true
	if step_mode_enabled:
		solver.step_executor = step_executor

## Sets the target position for IK solving
func set_target(target: Vector3) -> void:
	target_position = target
	if auto_solve:
		solve()

## Performs IK solving
func solve() -> void:
	if is_solving or not solver or not chain:
		push_warning("Cannot solve IK: Solver or chain not set, or already solving.")
		return
	print("Solving")
	is_solving = true
	var current_positions: Array[Vector3] = chain.get_positions()
	var new_positions: Array[Vector3] = solver.solve(current_positions, target_position)
	
	if not step_mode_enabled:
		chain.update_positions(new_positions)
		is_solving = false
		var final_error: float = new_positions[new_positions.size() - 1].distance_to(target_position)
		solve_completed.emit(new_positions, solver.max_iterations, final_error)
	else:
		is_solving = false

## Resets the chain to initial position
func reset_chain() -> void:
	if chain:
		chain.reset()

## Updates solver configuration
func configure_solver(new_max_iterations: int, new_tolerance: float) -> void:
	max_iterations = new_max_iterations
	tolerance = new_tolerance
	if solver:
		solver.max_iterations = max_iterations
		solver.tolerance = tolerance

## Enables or disables step-by-step mode
func set_step_mode(enabled: bool) -> void:
	step_mode_enabled = enabled
	if solver:
		solver.step_executor = step_executor if enabled else null
	if not enabled:
		step_executor.reset()

## Executes the next step in step mode
func execute_next_step() -> void:
	if not step_mode_enabled:
		push_warning("Step mode is not enabled")
		return
	step_executor.next_step()

## Checks if there are more steps available
func has_next_step() -> bool:
	return step_executor.has_next_step()

## Internal callback when a step is executed
func _on_step_executed(step_info: Dictionary) -> void:
	if chain:
		chain.update_positions(step_info["positions"])
	step_executed.emit(step_info)

## Internal callback when execution completes
func _on_execution_completed() -> void:
	var step_info: Dictionary = step_executor.get_current_step_info()
	if step_info.has("positions") and step_info.has("iteration") and step_info.has("error"):
		solve_completed.emit(step_info["positions"], step_info["iteration"], step_info["error"])

func _on_solve_button_pressed() -> void:
	solve()
