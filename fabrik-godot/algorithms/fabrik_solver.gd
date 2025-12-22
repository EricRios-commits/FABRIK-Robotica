## FABRIK (Forward And Backward Reaching Inverse Kinematics) algorithm implementation
## Implements Strategy Pattern through IKSolver base class
class_name FABRIKSolver extends IKSolver

## Solves IK using FABRIK algorithm
func solve(chain: Array[Vector3], target: Vector3, constraints: Array = []) -> Array[Vector3]:
	if not validate_chain(chain):
		return chain
	var positions: Array[Vector3] = chain.duplicate()
	var root = positions[0]
	var segment_lengths: Array[float] = []
	for i in range(positions.size() - 1):
		segment_lengths.append(positions[i].distance_to(positions[i + 1]))
	if not is_target_reachable(positions, target, root):
		var direction = (target - root).normalized()
		positions[0] = root
		for i in range(1, positions.size()):
			positions[i] = positions[i - 1] + direction * segment_lengths[i - 1]
		return positions
	
	var iteration: int = 0
	var distance_to_target = positions[positions.size() - 1].distance_to(target)
	
	# Iterate until close enough or max iterations reached
	while distance_to_target > tolerance and iteration < max_iterations:
		positions[positions.size() - 1] = target
		for i in range(positions.size() - 2, -1, -1):
			var direction = (positions[i] - positions[i + 1]).normalized()
			positions[i] = positions[i + 1] + direction * segment_lengths[i]
		positions[0] = root
		for i in range(positions.size() - 1):
			var direction = (positions[i + 1] - positions[i]).normalized()
			positions[i + 1] = positions[i] + direction * segment_lengths[i]
		distance_to_target = positions[positions.size() - 1].distance_to(target)
		iteration += 1
		if enable_debug:
			iteration_completed.emit(iteration, distance_to_target)
	return positions

func get_algorithm_name() -> String:
	return "FABRIK"
