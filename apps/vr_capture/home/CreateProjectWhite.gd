extends Button

@export var normal_color: Color = Color(1, 1, 1, 1)
@export var hover_color: Color = Color(0.9, 0.9, 0.9, 1)
@export var pressed_color: Color = Color(0.8, 0.8, 0.8, 1)
@export var transition_duration: float = 0.1

var _stylebox: StyleBoxFlat

func _ready() -> void:
	# Duplicate the normal stylebox to ensure uniqueness and use it for all states
	# to prevent layout shifts (size/spacing changes)
	var sb = get_theme_stylebox("normal")
	if sb is StyleBoxFlat:
		_stylebox = sb.duplicate()
		_stylebox.bg_color = normal_color
		
		# Apply the same stylebox to all states to ensure consistent layout
		add_theme_stylebox_override("normal", _stylebox)
		add_theme_stylebox_override("hover", _stylebox)
		add_theme_stylebox_override("pressed", _stylebox)
		add_theme_stylebox_override("disabled", _stylebox)
		add_theme_stylebox_override("focus", _stylebox)
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _animate_to_color(target_color: Color) -> void:
	if _stylebox:
		var tween = create_tween()
		tween.tween_property(_stylebox, "bg_color", target_color, transition_duration)

func _on_mouse_entered() -> void:
	if not button_pressed:
		_animate_to_color(hover_color)

func _on_mouse_exited() -> void:
	if not button_pressed:
		_animate_to_color(normal_color)

func _on_button_down() -> void:
	_animate_to_color(pressed_color)

func _on_button_up() -> void:
	if is_hovered():
		_animate_to_color(hover_color)
	else:
		_animate_to_color(normal_color)
