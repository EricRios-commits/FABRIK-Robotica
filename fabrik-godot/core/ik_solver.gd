## Abstract base class for IK solvers (Strategy Pattern)
## Follows Open/Closed Principle - open for extension, closed for modification
class_name IKSolver extends RefCounted

## Signal emitted when the solver updates the chain
signal iteration_completed(iteration: int, error: float)

## Configuration for the IK solver
var max_iterations: int = 10
var tolerance: float = 0.01
var enable_debug: bool = false

## Solves the IK problem for the given chain to reach the target position
## @param chain: Array of joint positions (Vector3)
## @param target: Target position to reach (Vector3)
## @param constraints: Optional constraints for each joint
## @return: Array of new joint positions
func solve(chain: Array[Vector3], target: Vector3, constraints: Array = []) -> Array[Vector3]:
	push_error("IKSolver.solve() must be implemented by subclass")
	return chain

## Gets the name of the algorithm
func get_algorithm_name() -> String:
	push_error("IKSolver.get_algorithm_name() must be implemented by subclass")
	return "Unknown"

## Validates if the chain is valid for solving
func validate_chain(chain: Array[Vector3]) -> bool:
	if chain.size() < 2:
		push_error("Chain must have at least 2 joints")
		return false
	return true

## Calculates the total length of the chain
func calculate_chain_length(chain: Array[Vector3]) -> float:
	var length: float = 0.0
	for i in range(chain.size() - 1):
		length += chain[i].distance_to(chain[i + 1])
	return length

## Checks if target is reachable
func is_target_reachable(chain: Array[Vector3], target: Vector3, root: Vector3) -> bool:
	var chain_length = calculate_chain_length(chain)
	var distance_to_target = root.distance_to(target)
	return distance_to_target <= chain_length
