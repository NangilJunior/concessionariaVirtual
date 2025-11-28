extends CanvasLayer

var _status_label: Label
var _speed_label: Label
var _frames_label: Label
var _warning_rect: ColorRect
var _guidance_label: Label
var _recording: bool = false
var _frames: int = 0

func _ready() -> void:
	var root := Control.new()
	add_child(root)
	root.anchors_preset = Control.PRESET_FULL_RECT
	_status_label = Label.new()
	root.add_child(_status_label)
	_status_label.position = Vector2(20, 20)
	_speed_label = Label.new()
	root.add_child(_speed_label)
	_speed_label.position = Vector2(20, 50)
	_frames_label = Label.new()
	root.add_child(_frames_label)
	_frames_label.position = Vector2(20, 80)
	_guidance_label = Label.new()
	root.add_child(_guidance_label)
	_guidance_label.position = Vector2(20, 110)
	_warning_rect = ColorRect.new()
	root.add_child(_warning_rect)
	_warning_rect.color = Color(1, 0, 0, 0.2)
	_warning_rect.visible = false
	_warning_rect.anchors_preset = Control.PRESET_FULL_RECT
	_update_labels()

func set_status(text: String) -> void:
	_status_label.text = text

func set_recording(active: bool) -> void:
	_recording = active
	_update_labels()

func increment_frame() -> void:
	_frames += 1
	_update_labels()

func set_speed(speed: float) -> void:
	_speed_label.text = "Velocidade: %.2f m/s" % speed

func warn_speed(active: bool) -> void:
	_warning_rect.visible = active

func set_guidance(text: String) -> void:
	_guidance_label.text = text

func _update_labels() -> void:
	_frames_label.text = "Frames: %d%s" % [_frames, (" (gravando)" if _recording else "")]

func _on_sync_status_changed(text: String) -> void:
	# Add a sync label if not exists or update it
	if not has_node("Control/SyncLabel"):
		var l = Label.new()
		l.name = "SyncLabel"
		$Control.add_child(l)
		l.position = Vector2(20, 140)
		l.add_theme_color_override("font_color", Color.CYAN)
	
	get_node("Control/SyncLabel").text = "Sync: " + text

func _enter_tree() -> void:
	# Connect to SyncManager if available (it's an autoload)
	if has_node("/root/SyncManager"):
		var sm = get_node("/root/SyncManager")
		if not sm.status_changed.is_connected(_on_sync_status_changed):
			sm.status_changed.connect(_on_sync_status_changed)
