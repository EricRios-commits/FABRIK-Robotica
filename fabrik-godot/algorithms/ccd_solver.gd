## CCD (Cyclic Coordinate Descent) algorithm implementation
## Implements Strategy Pattern through IKSolver base class
class_name CCDSolver extends IKSolver

## Solves IK using CCD algorithm
func solve(chain: Array[Vector3], target: Vector3, _constraints: Array = []) -> Array[Vector3]:
	if not validate_chain(chain):
		return chain
	if step_executor:
		step_executor.reset()
	var positions: Array[Vector3] = chain.duplicate()
	var end_effector_index: int = positions.size() - 1
	var segment_lengths: Array[float] = []
	for i in range(positions.size() - 1):
		segment_lengths.append(positions[i].distance_to(positions[i + 1]))
	var iteration: int = 0
	var distance_to_target: float = positions[end_effector_index].distance_to(target)
	if step_executor:
		step_executor.add_step(positions, 0, distance_to_target,
			"Initial chain configuration", "")
	while distance_to_target > tolerance and iteration < max_iterations:
		for i in range(end_effector_index - 1, -1, -1):
			var current_joint: Vector3 = positions[i]
			var end_effector: Vector3 = positions[end_effector_index]
			var to_end: Vector3 = (end_effector - current_joint).normalized()
			var to_target: Vector3 = (target - current_joint).normalized()
			var rotation_axis: Vector3 = to_end.cross(to_target)
			if rotation_axis.length() < 0.001:
				continue
			rotation_axis = rotation_axis.normalized()
			var angle: float = to_end.angle_to(to_target)
			var rotation: Basis = Basis(rotation_axis, angle)
			for j in range(i + 1, positions.size()):
				var relative_pos: Vector3 = positions[j] - current_joint
				positions[j] = current_joint + rotation * relative_pos
			if step_executor:
				step_executor.add_step(positions, iteration + 1, positions[end_effector_index].distance_to(target),
					"Iteration %d: Rotating joint %d" % [iteration + 1, i], "rotate")
			for j in range(i + 1, positions.size()):
				var direction: Vector3 = (positions[j] - positions[j - 1]).normalized()
				positions[j] = positions[j - 1] + direction * segment_lengths[j - 1]
			if step_executor:
				step_executor.add_step(positions, iteration + 1, positions[end_effector_index].distance_to(target),
					"Iteration %d: Restoring segment lengths after joint %d" % [iteration + 1, i], "restore")
		distance_to_target = positions[end_effector_index].distance_to(target)
		iteration += 1
		if enable_debug:
			iteration_completed.emit(iteration, distance_to_target)
	if step_executor:
		step_executor.add_step(positions, iteration, distance_to_target,
			"Final result - converged after %d iterations" % iteration, "final")
	return positions

func get_algorithm_name() -> String:
	return "CCD"
