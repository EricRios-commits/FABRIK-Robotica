## Draws a coordinate grid in configurable axis planes using lines.
class_name GridVisualizer extends MeshInstance3D

@export var grid_extent: int = 10
@export var step: float = 1.0
@export var color: Color = Color(0.6, 0.6, 0.6, 1.0)
@export var center_color: Color = Color(1.0, 0.0, 0.0, 1.0)
@export var show_axes: bool = true
@export var draw_xz: bool = false
@export var draw_xy: bool = false
@export var draw_yz: bool = false

func _ready() -> void:
	build_grid()

func set_grid_extent(v: int) -> void:
	grid_extent = max(0, v)
	build_grid()

func set_step(v: float) -> void:
	step = v if v > 0.0 else 1.0
	build_grid()
	
func _set_plane_visibility(xy: bool, xz: bool, yz: bool) -> void:
	draw_xy = xy
	draw_xz = xz
	draw_yz = yz
	build_grid()

func build_grid() -> void:
	var extent := int(grid_extent)
	var s := float(step) if step > 0.0 else 1.0
	var verts := PackedVector3Array()
	var cols := PackedColorArray()
	if draw_xz:
		_add_plane_lines(verts, cols, 0, 2, extent, s) # XZ plane (Y=0)
	if draw_xy:
		_add_plane_lines(verts, cols, 0, 1, extent, s) # XY plane (Z=0)
	if draw_yz:
		_add_plane_lines(verts, cols, 1, 2, extent, s) # YZ plane (X=0)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_COLOR] = cols
	var mesh := ArrayMesh.new()
	if verts.size() == 0:
		mesh = null
	else:
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
		var mat := StandardMaterial3D.new()
		mat.vertex_color_use_as_albedo = true
		mat.unshaded = true
		mesh.surface_set_material(0, mat)
	self.mesh = mesh

func _add_plane_lines(verts: PackedVector3Array, cols: PackedColorArray, axis_a: int, axis_b: int, extent: int, s: float) -> void:
	var other := 0
	for k in range(0, 3):
		if k != axis_a and k != axis_b:
			other = k
			break
	for i in range(-extent, extent + 1):
		var p := float(i) * s
		var coords := [0.0, 0.0, 0.0]
		coords[axis_a] = p
		coords[axis_b] = -extent * s
		coords[other] = 0.0
		verts.append(Vector3(coords[0], coords[1], coords[2]))
		coords[axis_b] = extent * s
		verts.append(Vector3(coords[0], coords[1], coords[2]))
		var c := center_color if show_axes and i == 0 else color
		cols.append(c)
		cols.append(c)
		coords = [0.0, 0.0, 0.0]
		coords[axis_a] = -extent * s
		coords[axis_b] = p
		coords[other] = 0.0
		verts.append(Vector3(coords[0], coords[1], coords[2]))
		coords[axis_a] = extent * s
		verts.append(Vector3(coords[0], coords[1], coords[2]))
		var c2 := center_color if show_axes and i == 0 else color
		cols.append(c2)
		cols.append(c2)

