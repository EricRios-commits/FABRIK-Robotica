## Step-by-step execution manager for IK algorithms
## Single Responsibility: Manages step execution state and progression
class_name StepExecutor extends RefCounted

## Emitted when a step is executed
signal step_executed(step_info: Dictionary)
## Emitted when execution completes
signal execution_completed()

## Step data structure
class StepData:
	var positions: Array[Vector3]
	var iteration: int
	var error: float
	var description: String
	var sub_step: String
	
	func _init(pos: Array[Vector3], iter: int, err: float, desc: String, sub: String = "") -> void:
		positions = pos.duplicate()
		iteration = iter
		error = err
		description = desc
		sub_step = sub

var steps: Array[StepData] = []
var current_step_index: int = -1
var is_step_mode: bool = false

## Clears all steps and resets state
func reset() -> void:
	steps.clear()
	current_step_index = -1

## Adds a new step to the sequence
func add_step(positions: Array[Vector3], iteration: int, error: float, description: String, sub_step: String = "") -> void:
	var step: StepData = StepData.new(positions, iteration, error, description, sub_step)
	steps.append(step)

## Executes the next step
## Returns true if there are more steps, false if completed
func next_step() -> bool:
	if current_step_index >= steps.size() - 1:
		execution_completed.emit()
		return false
	
	current_step_index += 1
	var step: StepData = steps[current_step_index]
	var step_info: Dictionary = {
		"positions": step.positions,
		"iteration": step.iteration,
		"error": step.error,
		"description": step.description,
		"sub_step": step.sub_step,
		"current_step": current_step_index + 1,
		"total_steps": steps.size()
	}
	step_executed.emit(step_info)
	return current_step_index < steps.size() - 1

## Skips to the end
func skip_to_end() -> void:
	if steps.is_empty():
		return
	
	current_step_index = steps.size() - 1
	var step: StepData = steps[current_step_index]
	var step_info: Dictionary = {
		"positions": step.positions,
		"iteration": step.iteration,
		"error": step.error,
		"description": "Final result",
		"sub_step": step.sub_step,
		"current_step": current_step_index + 1,
		"total_steps": steps.size()
	}
	step_executed.emit(step_info)
	execution_completed.emit()

## Returns whether there are more steps to execute
func has_next_step() -> bool:
	return current_step_index < steps.size() - 1

## Gets the total number of steps
func get_step_count() -> int:
	return steps.size()

## Gets current step info
func get_current_step_info() -> Dictionary:
	if current_step_index < 0 or current_step_index >= steps.size():
		return {}
	
	var step: StepData = steps[current_step_index]
	return {
		"positions": step.positions,
		"iteration": step.iteration,
		"error": step.error,
		"description": step.description,
		"sub_step": step.sub_step,
		"current_step": current_step_index + 1,
		"total_steps": steps.size()
	}



