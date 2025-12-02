class_name ClickableCard extends PanelContainer

signal pressed()

@export var hover_color_modulate: Color = Color(1.5, 1.5, 1.5, 1.0) # Lighten significantly
@export var pressed_color_modulate: Color = Color(0.9, 0.9, 0.9, 1.0) # Darken slightly

var _stylebox: StyleBoxFlat
var _original_color: Color

func _ready() -> void:
	# Duplicate stylebox to ensure unique instance for this node
	var sb = get_theme_stylebox("panel")
	if sb is StyleBoxFlat:
		_stylebox = sb.duplicate()
		add_theme_stylebox_override("panel", _stylebox)
		_original_color = _stylebox.bg_color
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_set_color(_original_color * pressed_color_modulate)
			else:
				_set_color(_original_color * hover_color_modulate) # Return to hover state
				if get_global_rect().has_point(get_global_mouse_position()):
					accept_event()
					pressed.emit()
				else:
					_set_color(_original_color) # Reset if released outside

func _on_mouse_entered() -> void:
	_set_color(_original_color * hover_color_modulate)

func _on_mouse_exited() -> void:
	_set_color(_original_color)

func _set_color(color: Color) -> void:
	if _stylebox:
		_stylebox.bg_color = color
