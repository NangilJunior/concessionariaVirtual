extends "res://home/clickable_card.gd"

signal delete_requested(project_id)
signal open_requested(project_id)
signal download_requested(project_id)

@onready var _title_label = $VBoxContainer2/MarginContainer/VBoxContainer/Title
@onready var _desc_label = $VBoxContainer2/MarginContainer/VBoxContainer/Label
@onready var _date_label = $VBoxContainer2/MarginContainer3/HBoxContainer/Label
@onready var _image_rect = $VBoxContainer2/TextureRect
@onready var _open_btn = $VBoxContainer2/MarginContainer2/HBoxContainer/CreateProject
@onready var _download_btn = $VBoxContainer2/MarginContainer2/HBoxContainer/BacktButton
@onready var _delete_btn = $VBoxContainer2/MarginContainer2/HBoxContainer/BacktButton2

@onready var _status_tag = %StatusTag
@onready var _status_label = %StatusLabel
@onready var _status_bg = %StatusTag.get_theme_stylebox("panel") # Access the stylebox to change color

var _project_data: Dictionary = {}

func _ready() -> void:
	super._ready()
	
	# Connect button signals
	if _open_btn.has_signal("pressed"):
		_open_btn.pressed.connect(_on_open_pressed)
	
	if _download_btn.has_signal("pressed"):
		_download_btn.pressed.connect(_on_download_pressed)
		
	if _delete_btn.has_signal("pressed"):
		_delete_btn.pressed.connect(_on_delete_pressed)

func setup(data: Dictionary) -> void:
	_project_data = data
	
	if "title" in data:
		_title_label.text = data["title"]
	if "description" in data:
		_desc_label.text = data["description"]
	if "created_at" in data:
		_date_label.text = data["created_at"].split("T")[0] 
	
	# Status Tag Logic
	var status = data.get("status", "created")
	_update_status_tag(status)
		
	_update_buttons_state()

func _update_status_tag(status: String) -> void:
	# Default hidden
	_status_tag.visible = false
	
	if status == "processing":
		_status_tag.visible = true
		_status_label.text = "Aguarde"
		_status_label.add_theme_color_override("font_color", Color.BLACK)
		if _status_bg is StyleBoxFlat:
			var color = Color.WHITE
			_status_bg.bg_color = Color(color.r, color.g, color.b, 0.75) # 75% opacity
			_status_bg.border_color = color # Solid border
			_set_stylebox_radius(_status_bg, 50)
			
	elif status == "ready" or status == "ready_to_view":
		_status_tag.visible = true
		_status_label.text = "Visualizar"
		_status_label.add_theme_color_override("font_color", Color.WHITE)
		if _status_bg is StyleBoxFlat:
			var color = Color.BLACK
			_status_bg.bg_color = Color(color.r, color.g, color.b, 0.05) # 5% opacity
			_status_bg.border_color = color # Solid border
			_set_stylebox_radius(_status_bg, 50)

func _set_stylebox_radius(sb: StyleBoxFlat, radius: int) -> void:
	# Set radius for all corners
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_right = radius
	sb.corner_radius_bottom_left = radius
	
	# Enforce border width to prevent visual glitches
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	
	# Ensure border is drawn on top
	sb.draw_center = true
	sb.set_expand_margin_all(0)

func _update_buttons_state() -> void:
	var status = _project_data.get("status", "created")
	var is_ready = status == "ready" or status == "ready_to_view"
	
	_open_btn.disabled = not is_ready
	_set_button_icon_enabled(_download_btn, is_ready)
	
	# Delete is always enabled
	_set_button_icon_enabled(_delete_btn, true)

func _set_button_icon_enabled(btn: Control, enabled: bool) -> void:
	if enabled:
		btn.modulate = Color(1, 1, 1, 1)
		btn.mouse_filter = Control.MOUSE_FILTER_PASS # Allow clicks
	else:
		btn.modulate = Color(0.5, 0.5, 0.5, 0.5)
		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE # Ignore clicks

func _on_open_pressed() -> void:
	emit_signal("open_requested", _project_data.get("id"))

func _on_download_pressed() -> void:
	emit_signal("download_requested", _project_data.get("id"))

func _on_delete_pressed() -> void:
	emit_signal("delete_requested", _project_data.get("id"))
