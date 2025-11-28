extends Control

@onready var _new_project_btn: ClickableCard = $"MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer3/HBoxContainer3/NewProject"
@onready var _open_project_btn: ClickableCard = $"MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer3/HBoxContainer3/OpenProject"
@onready var _logout_btn: ClickableCard = $"MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/LogoutButton"

func _ready() -> void:
	_new_project_btn.pressed.connect(_on_new_project_pressed)
	_open_project_btn.pressed.connect(_on_open_project_pressed)
	_logout_btn.pressed.connect(_on_logout_pressed)

func _on_new_project_pressed() -> void:
	print("[HomeScreen] New Project pressed")
	get_tree().change_scene_to_file("res://home/create_project_screen.tscn")

func _on_open_project_pressed() -> void:
	print("[HomeScreen] Open Project pressed")
	get_tree().change_scene_to_file("res://home/project_list_screen.tscn")

func _on_logout_pressed() -> void:
	print("[HomeScreen] Logout pressed")
	Auth.logout()
	get_tree().change_scene_to_file("res://login/login_screen.tscn")
