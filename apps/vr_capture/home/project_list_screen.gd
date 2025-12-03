extends Control

const ProjectsCardScene = preload("res://home/ProjectsCard.tscn")

@onready var _back_btn = $MarginContainer2/HBoxContainer/VBoxContainer/HBoxContainer2/BacktButton
@onready var _project_list_container: ScrollContainer = $ProjectList
@onready var _cards_container: HBoxContainer = $ProjectList/MarginContainer/HBoxContainer
@onready var _empty_state: VBoxContainer = $EmptyProject
@onready var _create_first_btn: Button = $EmptyProject/MarginContainer/CreateProject
@onready var _create_new_btn: Button = $MarginContainer2/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer3/HBoxContainer/CreateProject

# Modal
@onready var _modal: ColorRect = $ConfirmationModal
@onready var _modal_cancel_btn: Button = $ConfirmationModal/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CancelDelete
@onready var _modal_confirm_btn: Button = $ConfirmationModal/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ConfirmDelete

var _project_to_delete: String = ""

func _ready() -> void:
	_back_btn.pressed.connect(_on_back_pressed)
	_create_first_btn.pressed.connect(_on_create_pressed)
	_create_new_btn.pressed.connect(_on_create_pressed)
	
	_modal_cancel_btn.pressed.connect(_on_cancel_delete)
	_modal_confirm_btn.pressed.connect(_on_confirm_delete)
	
	ProjectManager.projects_updated.connect(_refresh_list)
	_refresh_list()

func _refresh_list() -> void:
	var projects = ProjectManager.get_projects()
	
	if projects.is_empty():
		_project_list_container.visible = false
		_empty_state.visible = true
	else:
		_project_list_container.visible = true
		_empty_state.visible = false
		_populate_cards(projects)

func _populate_cards(projects: Array) -> void:
	# Clear existing cards
	for child in _cards_container.get_children():
		child.queue_free()
	
	# Add new cards
	for project in projects:
		var card = ProjectsCardScene.instantiate()
		_cards_container.add_child(card)
		card.setup(project)
		
		card.delete_requested.connect(_on_delete_requested)
		card.open_requested.connect(_on_open_requested)
		card.download_requested.connect(_on_download_requested)

func _on_create_pressed() -> void:
	get_tree().change_scene_to_file("res://home/create_project_screen.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://home/home_screen.tscn")

func _on_delete_requested(project_id: String) -> void:
	_project_to_delete = project_id
	_modal.visible = true

func _on_confirm_delete() -> void:
	if _project_to_delete != "":
		ProjectManager.delete_project(_project_to_delete)
		_project_to_delete = ""
	_modal.visible = false

func _on_cancel_delete() -> void:
	_project_to_delete = ""
	_modal.visible = false

func _on_open_requested(project_id: String) -> void:
	print("Open requested for: ", project_id)
	# Logic to open project (e.g. load capture scene with data)

func _on_download_requested(project_id: String) -> void:
	print("Download requested for: ", project_id)
	# Logic to download PLY
