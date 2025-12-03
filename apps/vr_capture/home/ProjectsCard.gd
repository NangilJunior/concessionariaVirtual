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

var _project_data: Dictionary = {}

func _ready() -> void:
	super._ready()
	
	# Connect button signals
	# Note: We need to access the actual button inside the instanced scenes if they are wrapped
	# But based on the scene tree, CreateProject is a Button (from button.tscn)
	# BacktButton and BacktButton2 are ButtonIcon (PanelContainer with clickable_card.gd)
	
	if _open_btn.has_signal("pressed"):
		_open_btn.pressed.connect(_on_open_pressed)
	
	# For ButtonIcon instances (BacktButton), they use clickable_card.gd which emits "pressed"
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
		# Format date if needed, for now just show as is or simple format
		_date_label.text = data["created_at"].split("T")[0] 
	
	# Image handling
	# For now use default, or load if path exists
	if "local_path" in data and data["local_path"] != "":
		# Try to load first frame or thumbnail
		pass
		
	_update_buttons_state()

func _update_buttons_state() -> void:
	var status = _project_data.get("status", "created")
	var is_ready = status == "ready"
	
	_open_btn.disabled = not is_ready
	# For ButtonIcon (PanelContainer), "disabled" property might not exist or work visually
	# We might need to modulate opacity or disable input
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
