class_name ClickableCard extends PanelContainer

signal pressed()

@export var hover_color_modulate: Color = Color(1.5, 1.5, 1.5, 1.0) # Lighten significantly
@export var pressed_color_modulate: Color = Color(0.9, 0.9, 0.9, 1.0) # Darken slightly

var _stylebox: StyleBoxFlat
var _original_color: Color
var _pressed_pos: Vector2
var _is_pressed: bool = false

func _ready() -> void:
	# Duplicate stylebox to ensure unique instance for this node
	var sb = get_theme_stylebox("panel")
	if sb is StyleBoxFlat:
		_stylebox = sb.duplicate()
		add_theme_stylebox_override("panel", _stylebox)
		_original_color = _stylebox.bg_color
	
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_pressed = true
				_pressed_pos = event.global_position
				_set_color(_original_color * pressed_color_modulate)
			else:
				_is_pressed = false
				_set_color(_original_color * hover_color_modulate) # Return to hover state
				
				# Check if it was a click or a drag
				var drag_distance = _pressed_pos.distance_to(event.global_position)
				if drag_distance < 10.0: # Threshold for click
					if get_global_rect().has_point(get_global_mouse_position()):
						accept_event()
						pressed.emit()
				else:
					# It was a drag, do nothing (let ScrollContainer handle it)
					pass
					
				_set_color(_original_color) # Reset if released outside or dragged

func _on_mouse_entered() -> void:
	if not _is_pressed:
		_set_color(_original_color * hover_color_modulate)

func _on_mouse_exited() -> void:
	if not _is_pressed:
		_set_color(_original_color)

func _set_color(color: Color) -> void:
	if _stylebox:
		_stylebox.bg_color = color
