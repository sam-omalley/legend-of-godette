@tool
extends MultiMeshInstance3D

@export var mask: Texture2D
@export var surface: MeshInstance3D
@export var mesh_count: int = 100
@export var reload_on_tab_change: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multimesh.instance_count = mesh_count
	var mdt := MeshDataTool.new()
	mdt.create_from_surface(surface.mesh, 0)

	var image := mask.get_image()
	if image.is_compressed():
		image.decompress()
	
	var positions: Array = []
	var scales: Array = []

	for vtx in range(mdt.get_vertex_count()):
		var col = image.get_pixelv(mdt.get_vertex_uv(vtx) * Vector2(image.get_size()))
		if col.r < 0.8:
			var vert = mdt.get_vertex(vtx)
			var pos = surface.global_transform * vert
			scales.append((col.r + col.g + col.b) / 3.0)
			positions.append(pos)
	
	print(len(positions))
	print(mdt.get_vertex_count())
	print(scales.min(), " ", scales.max())


	for i in range(multimesh.instance_count):
		#var t: Transform3D = multimesh.get_instance_transform(i)
		#t.basis = basis
		#if t.basis.y.angle_to(basis.y) > deg_to_rad(5):
			#t = t.translated_local(t.basis.y * -100)
		#var t = Transform3D(basis, Vector3(positions.pick_random()))
		var idx = randi_range(0, len(positions) - 1)
		var t = Transform3D(basis, Vector3(positions[idx]))
		#t = t.scaled_local(Vector3.ONE * randf_range(0.5, 2) * (1.0 - scales[i]))
		t = t.scaled_local(Vector3.ONE * (1.0 - scales[idx]) * 3.0)
		t = t.rotated_local(basis.y.normalized(), randf() * PI)
		multimesh.set_instance_transform(i, t)

func _enter_tree() -> void:
	if reload_on_tab_change:
		request_ready()
