@tool
extends MultiMeshInstance3D

@export var mask: Texture2D:
	set(value):
		mask = value
		refresh()
@export var surface: MeshInstance3D:
	set(value):
		surface = value
		refresh()
@export var mesh_count: int = 100:
	set(value):
		mesh_count = value
		refresh()

@export var colour_mask: Color:
	set(value):
		colour_mask = value
		refresh()
@export var min_scale: float = 0.2:
	set(value):
		min_scale = value
		refresh()
@export var max_scale: float = 3.0:
	set(value):
		max_scale = value
		refresh()
@export var scale_randomisation: float = 0.0:
	set(value):
		scale_randomisation = value
		refresh()
@export var mask_threshold: float = 0.0:
	set(value):
		mask_threshold = value
		refresh()

# Hack to get a "reload" button. Never set value of checkbox to true.
@export var reload: bool = false:
	set(value):
		refresh()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()

func area_of_triangle(a: Vector3, b: Vector3, c: Vector3) -> float:
	var AB: Vector3 = b - a
	var AC: Vector3 = c - a

	return 0.5 * AB.cross(AC).length()

func subdivide_triangle(n: int, a: Vector3, b: Vector3, c: Vector3) -> Array:
	"""
	Subdivides a triangle defined by points A, B, C into n^2 smaller triangles.
	Returns an array of smaller triangles (each triangle is an array of 3 Vector3 points).
	"""
	var triangles = []  # Store the resulting smaller triangles

	# 1. Generate points along edges AB, AC, and BC
	var edge_ab = []
	var edge_ac = []
	for i in range(n + 1):
		var t = float(i) / n
		edge_ab.append(a.lerp(b, t))  # Points on AB
		edge_ac.append(a.lerp(c, t))  # Points on AC

	# 2. Generate grid points inside the triangle
	for i in range(n):  # For each row
		var row_points = []
		for j in range(i + 1):  # Points in the current row
			var t = float(j) / i if i > 0 else 0.0  # Avoid division by zero
			var point = edge_ab[i].linear_interpolate(edge_ac[i], t)
			row_points.append(point)

		# 3. Form triangles from this row and the next
		if i < n - 1:  # Stop before the last row
			for j in range(i + 1):
				# Form two triangles: upper and lower
				var p1 = row_points[j]
				var p2 = edge_ab[i + 1].linear_interpolate(edge_ac[i + 1], float(j) / (i + 1))
				var p3 = edge_ab[i + 1].linear_interpolate(edge_ac[i + 1], float(j + 1) / (i + 1))
				
				triangles.append([p1, p2, p3])  # Upper triangle

				if j < i:  # Lower triangle (except on the last point of the row)
					var p4 = row_points[j + 1]
					triangles.append([p1, p3, p4])

	return triangles

func log2(value: float) -> float:
	return log(value) / log(2)

func random_barycentric() -> Vector3:
	var r1: float = randf()
	var r2: float = randf()

	var u: float = 1.0 - sqrt(r1)
	var v: float = sqrt(r1) * (1.0 - r2)
	var w: float = sqrt(r1) * r2

	return Vector3(u, v, w)

func point_on_triangle(bary: Vector3, a: Vector3, b: Vector3, c: Vector3) -> Vector3:
	return a * bary.x + b * bary.y + c * bary.z

func interpolate_colour(bary: Vector3, a: Color, b: Color, c: Color) -> Color:
	return a * bary.x + b * bary.y + c * bary.z

func setup() -> void:
	if not surface or not surface.is_inside_tree():
		return
	# Set this to zero initially. Some parameters (like transform type) can't be
	# changed if this is > 0.
	multimesh.instance_count = 0
	multimesh.transform_format = MultiMesh.TRANSFORM_3D

	var mdt := MeshDataTool.new()
	mdt.create_from_surface(surface.mesh, 0)

	var image := mask.get_image()
	if image.is_compressed():
		image.decompress()
	
	var positions: Array = []
	var scales: Array = []

	#for vtx in range(mdt.get_vertex_count()):
		#var col = image.get_pixelv(mdt.get_vertex_uv2(vtx) * Vector2(image.get_size()))
		#col *= colour_mask
		#var shade: float = max(col.r, col.g, col.b)
		#if shade > mask_threshold:
			#var vert = mdt.get_vertex(vtx)
			#var pos = surface.global_transform * vert
			#scales.append(shade)
			#positions.append(pos)

	for face_idx in range(mdt.get_face_count()):
		var a_idx: int = mdt.get_face_vertex(face_idx, 0)
		var b_idx: int = mdt.get_face_vertex(face_idx, 1)
		var c_idx: int = mdt.get_face_vertex(face_idx, 2)

		var a: Vector3 = mdt.get_vertex(a_idx)
		var b: Vector3 = mdt.get_vertex(b_idx)
		var c: Vector3 = mdt.get_vertex(c_idx)

		var a_col: Color = image.get_pixelv(mdt.get_vertex_uv2(a_idx) * Vector2(image.get_size()))
		var b_col: Color = image.get_pixelv(mdt.get_vertex_uv2(b_idx) * Vector2(image.get_size()))
		var c_col: Color = image.get_pixelv(mdt.get_vertex_uv2(c_idx) * Vector2(image.get_size()))

		#var bcoord: Vector3 = Geometry3D.get_triangle_barycentric_coords(p, a, b, c)
		var bcoord := random_barycentric()

		var pos: Vector3 = point_on_triangle(bcoord, a, b, c)
		var col: Color = interpolate_colour(bcoord, a_col, b_col, c_col)
		col *= colour_mask
		var shade: float = max(col.r, col.g, col.b)

		if shade > mask_threshold:
			scales.append(shade)
			positions.append(surface.global_transform * pos)


	
	# Set this as late as possible to avoid Godot errors.
	multimesh.instance_count = mesh_count
	for i in range(multimesh.instance_count):
		#var t: Transform3D = multimesh.get_instance_transform(i)
		#t.basis = basis
		#if t.basis.y.angle_to(basis.y) > deg_to_rad(5):
			#t = t.translated_local(t.basis.y * -100)
		#var t = Transform3D(basis, Vector3(positions.pick_random()))
		if len(positions) == 0:
			print("Error: Not enough positions for instance_count")
			return
		var idx = randi_range(0, len(positions) - 1)
		var t = Transform3D(basis, Vector3(positions[idx]))
		#t = t.scaled_local(Vector3.ONE * randf_range(0.5, 2) * (1.0 - scales[i]))

		var new_scale: float = max_scale * (scales[idx])
		new_scale += randf_range(-scale_randomisation, scale_randomisation)
		new_scale = clampf(new_scale, min_scale, max_scale)

		t = t.scaled_local(Vector3.ONE * new_scale)
		t = t.rotated_local(basis.y.normalized(), randf() * PI)
		multimesh.set_instance_transform(i, t)

		# Ensure we can't use the same position twice
		positions.remove_at(idx)
		scales.remove_at(idx)

func refresh() -> void:
	if Engine.is_editor_hint():
		setup()
