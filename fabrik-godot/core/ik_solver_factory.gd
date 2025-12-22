## Factory for creating IK solvers (Factory Pattern)
## Follows Dependency Inversion Principle - returns abstractions, not concrete types
class_name IKSolverFactory extends RefCounted

enum SolverType {
	FABRIK,
	CCD
}

## Creates an IK solver based on the specified type
## @param type: The type of solver to create
## @return: An IKSolver instance
static func create_solver(type: SolverType) -> IKSolver:
	match type:
		SolverType.FABRIK:
			return FABRIKSolver.new()
		SolverType.CCD:
			return CCDSolver.new()
		_:
			push_error("Unknown solver type: " + str(type))
			return FABRIKSolver.new()

## Gets all available solver types
static func get_available_solvers() -> Array[String]:
	return ["FABRIK", "CCD"]

## Creates a solver by name
static func create_solver_by_name(name: String) -> IKSolver:
	match name.to_upper():
		"FABRIK":
			return create_solver(SolverType.FABRIK)
		"CCD":
			return create_solver(SolverType.CCD)
		_:
			push_error("Unknown solver name: " + name)
			return FABRIKSolver.new()
