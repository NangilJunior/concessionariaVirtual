extends Control

@onready var _name_input: LineEdit = $CenterContainer/VBoxContainer/NameInput
@onready var _description_input: TextEdit = $CenterContainer/VBoxContainer/DescriptionInput
@onready var _create_btn: Button = $CenterContainer/VBoxContainer/CreateButton
@onready var _back_btn: Button = $CenterContainer/VBoxContainer/BackButton

func _ready() -> void:
	_create_btn.pressed.connect(_on_create_pressed)
	_back_btn.pressed.connect(_on_back_pressed)

func _on_create_pressed() -> void:
	print("[CreateProject] Creating project: ", _name_input.text)
	# Logic to create project would go here
	get_tree().change_scene_to_file("res://capture/main.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://home/home_screen.tscn")
