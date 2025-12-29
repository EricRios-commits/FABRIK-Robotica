## UI Control panel for IK visualization (Single Responsibility - UI only)
class_name IKControlPanel extends Control

signal algorithm_changed(algorithm_name: String)
signal parameters_changed(max_iterations: int, tolerance: float)
signal reset_requested()
signal solve_requested()
signal next_step_requested()
signal joint_count_changed(count: int)
signal target_movement_toggled(enabled: bool)
signal auto_solve_toggled(enabled: bool)
signal set_target_position(position: Vector3)

@onready var algorithm_selector: OptionButton = $VBoxContainer/AlgorithmSelector
@onready var iteration_slider: HSlider = $VBoxContainer/IterationSlider
@onready var tolerance_slider: HSlider = $VBoxContainer/ToleranceSlider
@onready var iteration_label: Label = $VBoxContainer/IterationLabel
@onready var tolerance_label: Label = $VBoxContainer/ToleranceLabel
@onready var solve_button: Button = $VBoxContainer/SolveButton
@onready var reset_button: Button = $VBoxContainer/ResetButton
@onready var next_step_button: Button = $VBoxContainer/NextStepButton
@onready var step_info_label: Label = $VBoxContainer/StepInfoLabel
@onready var stats_label: Label = $VBoxContainer/StatsLabel
@onready var joint_count_label: Label = $VBoxContainer/JointCountLabel
@onready var joint_count_spinbox: SpinBox = $VBoxContainer/JointCountSpinBox
@onready var target_movement_checkbox: CheckBox = $VBoxContainer/TargetMovementCheckBox
@onready var auto_solve_checkbox: CheckBox = $VBoxContainer/AutoSolveCheckBox
@onready var target_position_x: SpinBox = $VBoxContainer/TargetPositionX
@onready var target_position_y: SpinBox = $VBoxContainer/TargetPositionY
@onready var target_position_z: SpinBox = $VBoxContainer/TargetPositionZ

func _ready() -> void:
	setup_ui()
	connect_signals()

func setup_ui() -> void:
	if algorithm_selector:
		algorithm_selector.clear()
		var solvers: Array = IKSolverFactory.get_available_solvers()
		for solver: String in solvers:
			algorithm_selector.add_item(solver)
	if iteration_slider:
		iteration_slider.min_value = 1
		iteration_slider.max_value = 100
		iteration_slider.value = 10
		update_iteration_label(10)
	if tolerance_slider:
		tolerance_slider.min_value = 0.001
		tolerance_slider.max_value = 1.0
		tolerance_slider.step = 0.001
		tolerance_slider.value = 0.01
		update_tolerance_label(0.01)
	if next_step_button:
		next_step_button.text = "Next Step"
	if step_info_label:
		step_info_label.text = ""
	if joint_count_label:
		joint_count_label.text = "Number of Links:"
	if joint_count_spinbox:
		joint_count_spinbox.min_value = 2
		joint_count_spinbox.max_value = 20
		joint_count_spinbox.step = 1
		joint_count_spinbox.value = 5
	if target_movement_checkbox:
		target_movement_checkbox.text = "Enable Target Movement"
		target_movement_checkbox.button_pressed = false
	if auto_solve_checkbox:
		auto_solve_checkbox.text = "Auto Solve"
		auto_solve_checkbox.button_pressed = false
	if target_position_x:
		target_position_x.min_value = -100.0
		target_position_x.max_value = 100.0
		target_position_x.step = 0.1
		target_position_x.value = 0.0
	if target_position_y:
		target_position_y.min_value = -100.0
		target_position_y.max_value = 100.0
		target_position_y.step = 0.1
		target_position_y.value = 0.0
	if target_position_z:
		target_position_z.min_value = -100.0
		target_position_z.max_value = 100.0
		target_position_z.step = 0.1
		target_position_z.value = 0.0

func connect_signals() -> void:
	if algorithm_selector:
		algorithm_selector.item_selected.connect(_on_algorithm_selected)
	if iteration_slider:
		iteration_slider.value_changed.connect(_on_iteration_changed)
	if tolerance_slider:
		tolerance_slider.value_changed.connect(_on_tolerance_changed)
	if solve_button:
		solve_button.pressed.connect(_on_solve_pressed)
	if next_step_button:
		next_step_button.pressed.connect(_on_next_step_pressed)
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)
	if joint_count_spinbox:
		joint_count_spinbox.value_changed.connect(_on_joint_count_changed)
	if target_movement_checkbox:
		target_movement_checkbox.toggled.connect(_on_target_movement_toggled)
	if auto_solve_checkbox:
		auto_solve_checkbox.toggled.connect(_on_auto_solve_toggled)
	if target_position_x:
		target_position_x.value_changed.connect(_on_target_position_changed)
	if target_position_y:
		target_position_y.value_changed.connect(_on_target_position_changed)
	if target_position_z:
		target_position_z.value_changed.connect(_on_target_position_changed)

func set_target_fields(position: Vector3) -> void:
	if target_position_x:
		target_position_x.value = position.x
	if target_position_y:
		target_position_y.value = position.y
	if target_position_z:
		target_position_z.value = position.z

func _on_target_position_changed(value: float) -> void:
	var pos: Vector3 = Vector3(
		target_position_x.value,
		target_position_y.value,
		target_position_z.value
	)
	set_target_position.emit(pos)

func _on_algorithm_selected(index: int) -> void:
	var algorithm_name: String = algorithm_selector.get_item_text(index)
	algorithm_changed.emit(algorithm_name)

func _on_iteration_changed(value: float) -> void:
	update_iteration_label(int(value))
	emit_parameters()

func _on_tolerance_changed(value: float) -> void:
	update_tolerance_label(value)
	emit_parameters()

func _on_solve_pressed() -> void:
	solve_requested.emit()

func _on_reset_pressed() -> void:
	reset_requested.emit()
	if step_info_label:
		step_info_label.text = ""

func _on_next_step_pressed() -> void:
	next_step_requested.emit()

func emit_parameters() -> void:
	if iteration_slider and tolerance_slider:
		parameters_changed.emit(int(iteration_slider.value), tolerance_slider.value)

func update_iteration_label(value: int) -> void:
	if iteration_label:
		iteration_label.text = "Max Iterations: " + str(value)

func update_tolerance_label(value: float) -> void:
	if tolerance_label:
		tolerance_label.text = "Tolerance: " + str(value)

func update_stats(iterations: int, error: float, algorithm: String) -> void:
	if stats_label:
		stats_label.text = "Algorithm: %s\nIterations: %d\nError: %.4f" % [algorithm, iterations, error]

func update_step_info(step_info: Dictionary) -> void:
	if step_info_label and step_info.has("description"):
		var text: String = "Step %d/%d\n%s\nError: %.4f" % [
			step_info.get("current_step", 0),
			step_info.get("total_steps", 0),
			step_info.get("description", ""),
			step_info.get("error", 0.0)
		]
		step_info_label.text = text

func _on_joint_count_changed(value: float) -> void:
	joint_count_changed.emit(int(value))

func _on_target_movement_toggled(pressed: bool) -> void:
	target_movement_toggled.emit(pressed)

func _on_auto_solve_toggled(pressed: bool) -> void:
	auto_solve_toggled.emit(pressed)

