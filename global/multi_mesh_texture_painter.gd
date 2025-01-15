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

	for vtx in range(mdt.get_vertex_count()):
		var col = image.get_pixelv(mdt.get_vertex_uv2(vtx) * Vector2(image.get_size()))
		col *= colour_mask
		var shade: float = max(col.r, col.g, col.b)
		if shade > mask_threshold:
			var vert = mdt.get_vertex(vtx)
			var pos = surface.global_transform * vert
			scales.append(shade)
			positions.append(pos)
	
	# Set this as late as possible to avoid Godot errors.
	multimesh.instance_count = mesh_count
	for i in range(multimesh.instance_count):
		#var t: Transform3D = multimesh.get_instance_transform(i)
		#t.basis = basis
		#if t.basis.y.angle_to(basis.y) > deg_to_rad(5):
			#t = t.translated_local(t.basis.y * -100)
		#var t = Transform3D(basis, Vector3(positions.pick_random()))
		var idx = randi_range(0, len(positions) - 1)
		var t = Transform3D(basis, Vector3(positions[idx]))
		#t = t.scaled_local(Vector3.ONE * randf_range(0.5, 2) * (1.0 - scales[i]))
		t = t.scaled_local(Vector3.ONE * clamp(max_scale * (scales[idx]), min_scale, max_scale))
		t = t.rotated_local(basis.y.normalized(), randf() * PI)
		multimesh.set_instance_transform(i, t)

func refresh() -> void:
	if Engine.is_editor_hint():
		setup()
