extends Node3D

var radius: float = 1.5
var segments: int = 24
var _next_index: int = 0
var _points: Array[Vector3] = []

func setup(center: Vector3) -> void:
	_points.clear()
	_next_index = 0
	for i in range(segments):
		var ang := TAU * float(i) / float(segments)
		var p := center + Vector3(cos(ang) * radius, 0, sin(ang) * radius)
		_points.append(p)

func update_next_target(current_pos: Vector3) -> void:
	if _points.is_empty():
		return
	var target: Vector3 = _points[_next_index]
	if current_pos.distance_to(target) < 0.3:
		_next_index = (_next_index + 1) % _points.size()

func current_hint() -> String:
	if _points.is_empty():
		return ""
	var target: Vector3 = _points[_next_index]
	return "Siga para: (%.2f, %.2f, %.2f)" % [target.x, target.y, target.z]