# Fabrik Godot — Inverse Kinematics Visualizer

## Introduction

This project was created for the Robotics course at University of La Laguna. 
Its goal is to showcase inverse kinematics (IK) algorithms in a visual and understandable way by providing an interactive 3D scene built with Godot Engine. 
Users can experiment with different IK algorithms (currently FABRIK and CCD), observe step-by-step solving, tune parameters, and visualize how joint chains move to reach a target.

## Contents

- scenes/: Godot scene files (main.tscn and main_scene.gd) that wire all components together.
- core/: Core runtime logic for IK: chain representation, controller, solver factory and shared utilities.
- algorithms/: Solver implementations (FABRIK, CCD) following a common IKSolver interface/base class.
- ui/: UI control panel script to interact with the simulation (select algorithm, parameters, target, etc.).
- visualization/: Visualizer scripts that render joints, segments and the target in the 3D scene.
- project.godot, export_presets.cfg: Godot project files.

## Quick start

## Prerequisites

- Godot Engine 4.x (the project uses Node3D, Camera3D and Godot 4 style API).

## Run the project

1. Open Godot and load the project folder (the folder containing `project.godot`).
2. Open the scene `res://scenes/main.tscn` and run it (F5).
3. The UI overlay provides controls to select algorithms, change chain length, move the target and tune solver parameters.

## User interface and controls

- Algorithm: choose between available solvers (FABRIK, CCD).
- Number of Links: set the joint count (minimum 2).
- Enable Target Movement: if enabled, you can drag the target in the 3D view with the left mouse button.
- Auto Solve: when enabled, changing the target will automatically trigger a solve.
- Target Position (X, Y, Z): numeric fields to place the target precisely.
- Tolerance and Max Iterations: solver configuration (tolerance for stopping and iteration cap).
- Solve IK: runs the solver immediately.
- Next Step: runs the next step in step-by-step mode (useful to inspect intermediate passes).
- Reset: restores the chain to its initial straight configuration.
- Camera Yaw/Pitch/Zoom: orbit the camera around the chain.
- Grid checkboxes (XY/XZ/YZ): show/hide grid planes.

## How it works (high level)

The project is split into small, single-responsibility components:

- IKChain (`core/ik_chain.gd`)
  - Represents the kinematic chain as a list of joints (Node3D instances).
  - Manages joint creation, positions, and resetting.
  - Emits `chain_updated(positions)` whenever joint positions change.

- IKSolver interface (core/ik_solver.gd — base class)
  - Provides a common API for solvers: `solve(chain_positions, target, constraints)` and configuration fields such as `max_iterations` and `tolerance`.
  - Supports an optional `step_executor` to produce intermediate steps for visualization.

- FABRIK (`algorithms/fabrik_solver.gd`)
  - Implements the FABRIK algorithm (Forward And Backward Reaching Inverse Kinematics).
  - If target unreachable, stretches the chain towards the target.
  - If step execution is enabled, it pushes intermediate steps to the `StepExecutor` for inspection.

- CCD (`algorithms/ccd_solver.gd`)
  - Implements Cyclic Coordinate Descent.
  - Iteratively rotates joints (from end effector towards root) to reduce the distance to the target.
  - Also supports step execution for debugging and teaching.

- IKController (`core/ik_controller.gd`)
  - Coordinates the chain, the selected solver, and the visualizers.
  - Accepts target updates, config changes, and exposes `solve()`, `reset_chain()`, and step-mode controls.
  - Connects solver outputs to the `IKChain` (updates joint positions) and emits `solve_completed` events.

- Visualizers
  - ChainVisualizer (`visualization/chain_visualizer.gd`): creates sphere meshes for joints and cylinder meshes for segments, updates them on `chain_updated`.
  - TargetVisualizer (`visualization/target_visualizer.gd`): renders and manages the target position.
  - GridVisualizer (`visualization/grid_visualizer.gd`): draws XY/XZ/YZ planes for reference.

- UI
  - IKControlPanel (`ui/ik_control_panel.gd`): the in-game UI (OptionButton, sliders, checkboxes, spinboxes) which emits signals like `algorithm_changed`, `parameters_changed`, `set_target_position`, etc.
  - `scenes/main_scene.gd` wires the UI, controller and visualizers and translates user inputs (mouse drags, camera orbit) into actions.

## Data flow

1. The UI or mouse input changes the target position (or solver parameters).
2. `IKController` receives new target or parameters and calls the selected solver's `solve(...)` method.
3. The solver computes new joint positions and returns them (or emits step events if step mode is enabled).
4. `IKController` updates the `IKChain` with new positions.
5. `IKChain` emits `chain_updated`, the `ChainVisualizer` updates meshes to reflect new positions.
6. UI is updated with statistics (iterations, final error) when solving completes.

## Extensibility

- Adding a new solver:
  - Create a new script under `algorithms/` extending the IKSolver base.
  - Implement `solve(chain_positions, target, constraints)` and `get_algorithm_name()`.
  - Register it in the `IKSolverFactory` so it appears in the UI.

- Constraints and joint limits:
  - The solver signatures accept an optional `constraints` array — the current project includes hook points to apply limits, but you can extend the solvers to use constraint data.

- Visualization improvements:
  - Replace primitive meshes with custom glTF models or improve materials in `visualization/*`.
  - Add trajectory traces, heatmaps, or additional debugging overlays.

## Developer notes

- This project targets Godot 4.x.
- Main scene: `res://scenes/main.tscn`.
- Core scripts: `res://core/`.
- Algorithm implementations: `res://algorithms/`.
- UI: `res://ui/`.
- Visualization: `res://visualization/`.

## License

This project is licensed under the MIT License.
If you intend to reuse code in another project, credit the original author and the University of La Laguna.

## Contact / Attribution

Created as an assignment for the Robotics course at University of La Laguna to illustrate inverse kinematics algorithms interactively. 
For questions about the implementation or to suggest improvements, open an issue.

