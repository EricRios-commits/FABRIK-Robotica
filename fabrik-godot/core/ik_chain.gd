## Represents a kinematic chain of joints (Single Responsibility)
## Manages the chain data structure and basic operations
class_name IKChain extends Node3D

## Emitted when the chain is updated
signal chain_updated(positions: Array[Vector3])

## Joint nodes in the chain
@export var joint_count: int = 5
@export var segment_length: float = 1.0
@export var initial_orientation: Vector3 = Vector3.DOWN

var joints: Array[Node3D] = []
var joint_positions: Array[Vector3] = []

func _ready() -> void:
	if joints.is_empty():
		create_default_chain()

## Creates a default chain if none exists
func create_default_chain() -> void:
	var direction: Vector3 = initial_orientation.normalized()
	var current_pos: Vector3 = Vector3.ZERO
	for i in range(joint_count):
		var joint: Node3D = Node3D.new()
		joint.name = "Joint_" + str(i)
		joint.position = current_pos
		add_child(joint)
		joints.append(joint)
		joint_positions.append(current_pos)
		current_pos += direction * segment_length

## Gets current positions of all joints
func get_positions() -> Array[Vector3]:
	joint_positions.clear()
	for joint in joints:
		joint_positions.append(joint.global_position)
	return joint_positions

## Updates joint positions
func update_positions(new_positions: Array[Vector3]) -> void:
	if new_positions.size() != joints.size():
		push_error("Position array size mismatch")
		return
	for i in range(joints.size()):
		joints[i].global_position = new_positions[i]
	joint_positions = new_positions.duplicate()
	chain_updated.emit(joint_positions)

## Gets the root position
func get_root_position() -> Vector3:
	if joints.is_empty():
		return Vector3.ZERO
	return joints[0].global_position

## Gets the end effector position
func get_end_effector_position() -> Vector3:
	if joints.is_empty():
		return Vector3.ZERO
	return joints[joints.size() - 1].global_position

## Resets chain to initial configuration
func reset() -> void:
	if joints.is_empty():
		return
	var direction: Vector3 = initial_orientation.normalized()
	var current_pos: Vector3 = get_root_position()
	for i in range(joints.size()):
		joints[i].global_position = current_pos
		current_pos += direction * segment_length
	chain_updated.emit(get_positions())


