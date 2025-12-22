## UI Control panel for IK visualization (Single Responsibility - UI only)
class_name IKControlPanel extends Control

signal algorithm_changed(algorithm_name: String)
signal parameters_changed(max_iterations: int, tolerance: float)
signal reset_requested()

@onready var algorithm_selector: OptionButton = $VBoxContainer/AlgorithmSelector
@onready var iteration_slider: HSlider = $VBoxContainer/IterationSlider
@onready var tolerance_slider: HSlider = $VBoxContainer/ToleranceSlider
@onready var iteration_label: Label = $VBoxContainer/IterationLabel
@onready var tolerance_label: Label = $VBoxContainer/ToleranceLabel
@onready var reset_button: Button = $VBoxContainer/ResetButton
@onready var stats_label: Label = $VBoxContainer/StatsLabel

func _ready():
	setup_ui()
	connect_signals()

func setup_ui():
	if algorithm_selector:
		algorithm_selector.clear()
		var solvers = IKSolverFactory.get_available_solvers()
		for solver in solvers:
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

func connect_signals():
	if algorithm_selector:
		algorithm_selector.item_selected.connect(_on_algorithm_selected)
	if iteration_slider:
		iteration_slider.value_changed.connect(_on_iteration_changed)
	if tolerance_slider:
		tolerance_slider.value_changed.connect(_on_tolerance_changed)
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)

func _on_algorithm_selected(index: int):
	var algorithm_name = algorithm_selector.get_item_text(index)
	algorithm_changed.emit(algorithm_name)

func _on_iteration_changed(value: float):
	update_iteration_label(int(value))
	emit_parameters()

func _on_tolerance_changed(value: float):
	update_tolerance_label(value)
	emit_parameters()

func _on_reset_pressed():
	reset_requested.emit()

func emit_parameters():
	if iteration_slider and tolerance_slider:
		parameters_changed.emit(int(iteration_slider.value), tolerance_slider.value)

func update_iteration_label(value: int):
	if iteration_label:
		iteration_label.text = "Max Iterations: " + str(value)

func update_tolerance_label(value: float):
	if tolerance_label:
		tolerance_label.text = "Tolerance: " + str(value)

func update_stats(iterations: int, error: float, algorithm: String):
	if stats_label:
		stats_label.text = "Algorithm: %s\nIterations: %d\nError: %.4f" % [algorithm, iterations, error]
