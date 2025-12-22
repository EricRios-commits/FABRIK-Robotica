## FABRIK (Forward And Backward Reaching Inverse Kinematics) algorithm implementation
## Implements Strategy Pattern through IKSolver base class
class_name FABRIKSolver extends IKSolver

## Solves IK using FABRIK algorithm
func solve(chain: Array[Vector3], target: Vector3, _constraints: Array = []) -> Array[Vector3]:
	print("Solving with FABRIK Solver")
	if not validate_chain(chain):
		push_error("Invalid chain provided to FABRIK solver.")
		return chain
	
	if step_executor:
		step_executor.reset()
	
	var positions: Array[Vector3] = chain.duplicate()
	var root: Vector3 = positions[0]
	var segment_lengths: Array[float] = []
	
	for i in range(positions.size() - 1):
		segment_lengths.append(positions[i].distance_to(positions[i + 1]))
	
	# Record initial state
	if step_executor:
		step_executor.add_step(positions, 0, positions[positions.size() - 1].distance_to(target), 
			"Initial chain configuration", "")
	
	if not is_target_reachable(positions, target, root):
		var direction: Vector3 = (target - root).normalized()
		positions[0] = root
		for i in range(1, positions.size()):
			positions[i] = positions[i - 1] + direction * segment_lengths[i - 1]
		
		if step_executor:
			step_executor.add_step(positions, 0, positions[positions.size() - 1].distance_to(target),
				"Target unreachable - stretching toward target", "")
		return positions
	
	var iteration: int = 0
	var distance_to_target: float = positions[positions.size() - 1].distance_to(target)
	
	# Iterate until close enough or max iterations reached
	while distance_to_target > tolerance and iteration < max_iterations:
		# Backward pass
		positions[positions.size() - 1] = target
		if step_executor:
			step_executor.add_step(positions, iteration + 1, distance_to_target,
				"Iteration %d: Backward pass start" % (iteration + 1), "backward_start")
		
		for i in range(positions.size() - 2, -1, -1):
			var direction: Vector3 = (positions[i] - positions[i + 1]).normalized()
			positions[i] = positions[i + 1] + direction * segment_lengths[i]
			
			if step_executor:
				step_executor.add_step(positions, iteration + 1, distance_to_target,
					"Iteration %d: Backward pass - adjusting joint %d" % [iteration + 1, i], "backward")
		
		# Forward pass
		positions[0] = root
		if step_executor:
			step_executor.add_step(positions, iteration + 1, distance_to_target,
				"Iteration %d: Forward pass start" % (iteration + 1), "forward_start")
		
		for i in range(positions.size() - 1):
			var direction: Vector3 = (positions[i + 1] - positions[i]).normalized()
			positions[i + 1] = positions[i] + direction * segment_lengths[i]
			
			if step_executor:
				step_executor.add_step(positions, iteration + 1, positions[positions.size() - 1].distance_to(target),
					"Iteration %d: Forward pass - adjusting joint %d" % [iteration + 1, i + 1], "forward")
		
		distance_to_target = positions[positions.size() - 1].distance_to(target)
		iteration += 1
		
		if enable_debug:
			iteration_completed.emit(iteration, distance_to_target)
	
	# Record final state
	if step_executor:
		step_executor.add_step(positions, iteration, distance_to_target,
			"Final result - converged after %d iterations" % iteration, "final")
	
	return positions

func get_algorithm_name() -> String:
	return "FABRIK"
