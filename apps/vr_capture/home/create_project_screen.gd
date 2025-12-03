extends Control

# Inputs
@onready var _name_input: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer3/VBoxContainer2/Email/LineEdit
@onready var _desc_input: TextEdit = $MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer3/VBoxContainer2/VBoxContainer/TextEdit

# Buttons
@onready var _create_btn: Button = $MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer3/HBoxContainer/CreateProject
@onready var _cancel_btn: Button = $MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer3/HBoxContainer/Button
@onready var _back_btn: Control = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/BacktButton

func _ready() -> void:
	_create_btn.pressed.connect(_on_create_pressed)
	_cancel_btn.pressed.connect(_on_cancel_pressed)
	_desc_input.text_changed.connect(_on_desc_text_changed)
	
	# Back button is a ClickableCard (PanelContainer), so it emits 'pressed'
	if _back_btn.has_signal("pressed"):
		_back_btn.pressed.connect(_on_back_pressed)
	else:
		# Fallback if it's just a control without the script for some reason, though it should have it
		print_debug("Back button missing pressed signal")

func _on_create_pressed() -> void:
	var project_name = _name_input.text
	var project_desc = _desc_input.text
	
	if project_name.strip_edges().is_empty():
		print("[CreateProject] Name is empty!")
		return
		
	print("[CreateProject] Creating project: ", project_name, " - ", project_desc)
	
	# Save project
	ProjectManager.create_project(project_name, project_desc)
	
	# Proceed to capture screen
	get_tree().change_scene_to_file("res://capture/main.tscn")

func _on_cancel_pressed() -> void:
	print("[CreateProject] Cancelled")
	_go_home()

func _on_back_pressed() -> void:
	print("[CreateProject] Back pressed")
	_go_home()

func _go_home() -> void:
	get_tree().change_scene_to_file("res://home/home_screen.tscn")

func _on_desc_text_changed() -> void:
	if _desc_input.text.length() > 250:
		_desc_input.text = _desc_input.text.left(250)
		_desc_input.set_caret_line(_desc_input.get_line_count()) # Move cursor to end
		_desc_input.set_caret_column(_desc_input.get_line_width(_desc_input.get_line_count() - 1))
