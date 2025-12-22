## CCD (Cyclic Coordinate Descent) algorithm implementation
## Implements Strategy Pattern through IKSolver base class
class_name CCDSolver extends IKSolver

## Solves IK using CCD algorithm
func solve(chain: Array[Vector3], target: Vector3, constraints: Array = []) -> Array[Vector3]:
	if not validate_chain(chain):
		return chain
	var positions: Array[Vector3] = chain.duplicate()
	var root = positions[0]
	var end_effector_index = positions.size() - 1
	var segment_lengths: Array[float] = []
	for i in range(positions.size() - 1):
		segment_lengths.append(positions[i].distance_to(positions[i + 1]))
	var iteration: int = 0
	var distance_to_target = positions[end_effector_index].distance_to(target)
	while distance_to_target > tolerance and iteration < max_iterations:
		for i in range(end_effector_index - 1, -1, -1):
			var current_joint = positions[i]
			var end_effector = positions[end_effector_index]
			var to_end = (end_effector - current_joint).normalized()
			var to_target = (target - current_joint).normalized()
			var rotation_axis = to_end.cross(to_target)
			if rotation_axis.length() < 0.001:
				continue
			rotation_axis = rotation_axis.normalized()
			var angle = to_end.angle_to(to_target)
			var rotation = Basis(rotation_axis, angle)
			for j in range(i + 1, positions.size()):
				var relative_pos = positions[j] - current_joint
				positions[j] = current_joint + rotation * relative_pos
			for j in range(i + 1, positions.size()):
				var direction = (positions[j] - positions[j - 1]).normalized()
				positions[j] = positions[j - 1] + direction * segment_lengths[j - 1]
		distance_to_target = positions[end_effector_index].distance_to(target)
		iteration += 1
		if enable_debug:
			iteration_completed.emit(iteration, distance_to_target)
	return positions

func get_algorithm_name() -> String:
	return "CCD"
