## Controller that manages IK solving for a chain (Single Responsibility)
## Coordinates between the chain, solver, and visualization
class_name IKController extends Node

## Emitted when solving is complete
signal solve_completed(positions: Array[Vector3], iterations: int, final_error: float)

@export var auto_solve: bool = false
@export var max_iterations: int = 10
@export var tolerance: float = 0.01

var chain: IKChain
var solver: IKSolver
var target_position: Vector3 = Vector3.ZERO
var is_solving: bool = false

func _ready():
	chain = get_node_or_null("../IKChain")
	set_solver(IKSolverFactory.SolverType.FABRIK)

## Sets the IK solver to use
func set_solver(solver_type: IKSolverFactory.SolverType):
	solver = IKSolverFactory.create_solver(solver_type)
	solver.max_iterations = max_iterations
	solver.tolerance = tolerance
	solver.enable_debug = true

## Sets the solver by name
func set_solver_by_name(solver_name: String):
	solver = IKSolverFactory.create_solver_by_name(solver_name)
	solver.max_iterations = max_iterations
	solver.tolerance = tolerance
	solver.enable_debug = true

## Sets the target position for IK solving
func set_target(target: Vector3):
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
	var current_positions := chain.get_positions()
	var new_positions := solver.solve(current_positions, target_position)
	chain.update_positions(new_positions)
	is_solving = false
	var final_error = new_positions[new_positions.size() - 1].distance_to(target_position)
	solve_completed.emit(new_positions, solver.max_iterations, final_error)

## Resets the chain to initial position
func reset_chain():
	if chain:
		chain.reset()

## Updates solver configuration
func configure_solver(new_max_iterations: int, new_tolerance: float):
	max_iterations = new_max_iterations
	tolerance = new_tolerance
	if solver:
		solver.max_iterations = max_iterations
		solver.tolerance = tolerance


func _on_solve_button_pressed() -> void:
	solve()
