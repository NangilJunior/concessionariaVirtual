extends Control

@onready var _new_project_btn: Button = $CenterContainer/VBoxContainer/NewProjectButton
@onready var _open_project_btn: Button = $CenterContainer/VBoxContainer/OpenProjectButton
@onready var _logout_btn: Button = $CenterContainer/VBoxContainer/LogoutButton

func _ready() -> void:
	_new_project_btn.pressed.connect(_on_new_project_pressed)
	_open_project_btn.pressed.connect(_on_open_project_pressed)
	_logout_btn.pressed.connect(_on_logout_pressed)

func _on_new_project_pressed() -> void:
	print("[HomeScreen] New Project pressed")
	# For now, go to capture screen as a placeholder for "starting a project"
	get_tree().change_scene_to_file("res://capture/main.tscn")

func _on_open_project_pressed() -> void:
	print("[HomeScreen] Open Project pressed")
	# Placeholder
	pass

func _on_logout_pressed() -> void:
	print("[HomeScreen] Logout pressed")
	Auth.logout()
	get_tree().change_scene_to_file("res://login/login_screen.tscn")
