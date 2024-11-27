extends Object

class_name Debug

static func makeDebugNode(size: float, color: Color) -> MeshInstance3D:
	var box = BoxMesh.new()
	box.size = Vector3(size, size, size)
	var mesh = MeshInstance3D.new()
	mesh.mesh = box
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	mesh.set_surface_override_material(0, material)
	return mesh

	
