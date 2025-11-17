extends Node

var speed_threshold: float = 1.5
var _prev_pos: Vector3 = Vector3.ZERO
var _initialized: bool = false

func measure_speed(current_pos: Vector3, delta: float) -> float:
	if not _initialized:
		_prev_pos = current_pos
		_initialized = true
		return 0.0
	var dist := _prev_pos.distance_to(current_pos)
	_prev_pos = current_pos
	if delta <= 0.0:
		return 0.0
	return dist / delta

func is_too_fast(speed: float) -> bool:
	return speed > speed_threshold