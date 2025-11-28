class_name SplashScreen extends Control


@export var _time: float = 3
@export var _fade_time: float = 1

signal finished()


func start() -> void:
	print("[SplashScreen] Starting splash screen: ", name)
	modulate.a = 0
	show()
	var tween: Tween = create_tween()
	tween.finished.connect(_finish)
	tween.tween_property(self, "modulate:a", 1, _fade_time)
	tween.tween_interval(_time)
	tween.tween_property(self,"modulate:a", 0, _fade_time)
	print("[SplashScreen] Tween created. Total time: ", _fade_time + _time + _fade_time, "s")


func _finish() -> void:
	print("[SplashScreen] Finished: ", name)
	finished.emit()
	queue_free()

