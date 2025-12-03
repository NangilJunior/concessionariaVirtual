extends Node

signal projects_updated

const SAVE_PATH = "user://projects.json"

var _projects: Array = []

func _ready() -> void:
	load_projects()

func create_project(title: String, description: String) -> Dictionary:
	var project = {
		"id": _generate_uuid(),
		"title": title,
		"description": description,
		"created_at": Time.get_datetime_string_from_system(),
		"status": "created", # created, uploading, processing, ready, error
		"local_path": "", # Will be set when capture starts
		"ply_url": ""
	}
	_projects.append(project)
	save_projects()
	emit_signal("projects_updated")
	return project

func delete_project(project_id: String) -> void:
	for i in range(_projects.size()):
		if _projects[i]["id"] == project_id:
			_projects.remove_at(i)
			save_projects()
			emit_signal("projects_updated")
			return

func get_projects() -> Array:
	return _projects

func get_project(project_id: String) -> Dictionary:
	for p in _projects:
		if p["id"] == project_id:
			return p
	return {}

func update_project_status(project_id: String, status: String) -> void:
	var p = get_project(project_id)
	if not p.is_empty():
		p["status"] = status
		save_projects()
		emit_signal("projects_updated")

func save_projects() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_projects))
		file.close()

func load_projects() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		if data is Array:
			_projects = data
		file.close()

func _generate_uuid() -> String:
	# Simple UUID generation for Godot 4
	# In a real app, use a proper UUID library or the OS specific method if available
	# For now, a random string + timestamp is sufficient for local usage
	var chars = "0123456789abcdef"
	var uuid = ""
	for i in range(32):
		uuid += chars[randi() % chars.length()]
	return uuid
