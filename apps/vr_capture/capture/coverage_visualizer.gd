extends Node3D

var cell_size: float = 0.5
var _visited := {}

func reset() -> void:
	_visited.clear()
	for child in get_children():
		child.queue_free()

func add_sample(pos: Vector3) -> void:
	var key := Vector3i(floor(pos.x / cell_size), floor(pos.y / cell_size), floor(pos.z / cell_size))
	if _visited.has(key):
		return
	_visited[key] = true
	var m := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.05
	m.mesh = sphere
	m.transform.origin = Vector3(key.x * cell_size, key.y * cell_size, key.z * cell_size)
	add_child(m)