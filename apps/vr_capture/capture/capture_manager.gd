extends Node3D

@onready var xr_camera: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var speed_monitor: Node = $SpeedMonitor
@onready var recorder: Node = $Recorder
@onready var coverage: Node3D = $CoverageVisualizer
@onready var path_guide: Node3D = $PathGuide
@onready var hud: CanvasLayer = $HUD

var capturing: bool = false
var capture_interval_sec: float = 0.1 # Aumentado para 10 FPS para Gaussian Splatting
var _capture_timer: float = 0.0

func _ready() -> void:
	hud.call("set_status", "Pronto para capturar")
	path_guide.call("setup", xr_camera.global_transform.origin)
	coverage.call("reset")
	
	# Connect to Guide Modal
	var modal = hud.call("get_guide_modal")
	if modal:
		modal.step_started.connect(_on_step_started)
		modal.step_completed.connect(_on_step_completed)
		modal.capture_finished.connect(_on_capture_finished)

func _on_step_started(step_index: int) -> void:
	print("Step started: ", step_index)
	match step_index:
		0: # Mapping
			hud.call("set_status", "Mapeando área...")
			# Enable grid/mapping visualizer here
		1: # Capture
			start_capture()
		2: # Detailing
			hud.call("set_status", "Capturando detalhes...")
			# Change visualizer color or mode

func _on_step_completed(step_index: int) -> void:
	print("Step completed: ", step_index)

func _on_capture_finished() -> void:
	print("Capture finished")
	stop_capture()
	
	# Update project status
	if not ProjectManager.current_project.is_empty():
		ProjectManager.update_project_status(ProjectManager.current_project["id"], "processing")
	
	# Navigate to Project List
	get_tree().change_scene_to_file("res://home/project_list_screen.tscn")


func start_capture() -> void:
	capturing = true
	_capture_timer = 0.0
	recorder.call("start_session")
	hud.call("set_status", "Capturando")
	hud.call("set_recording", true)

func stop_capture() -> void:
	capturing = false
	recorder.call("end_session")
	hud.call("set_status", "Captura finalizada")
	hud.call("set_recording", false)

func _process(delta: float) -> void:
	if capturing:
		_capture_timer += delta
		if _capture_timer >= capture_interval_sec:
			_capture_timer = 0.0
			var pose := xr_camera.global_transform
			var viewport := get_viewport()
			recorder.call("capture_frame", viewport, xr_camera, pose)
			coverage.call("add_sample", pose.origin)
			hud.call("increment_frame")
		var speed: float = float(speed_monitor.call("measure_speed", xr_camera.global_transform.origin, delta))
		hud.call("set_speed", speed)
		if speed_monitor.call("is_too_fast", speed):
			hud.call("warn_speed", true)
		else:
			hud.call("warn_speed", false)
		path_guide.call("update_next_target", xr_camera.global_transform.origin)
		hud.call("set_guidance", path_guide.call("current_hint"))
		path_guide.call("update_next_target", xr_camera.global_transform.origin)
		hud.call("set_guidance", path_guide.call("current_hint"))
