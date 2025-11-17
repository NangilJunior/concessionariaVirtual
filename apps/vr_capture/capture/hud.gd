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