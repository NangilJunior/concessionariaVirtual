extends Node

signal sync_started
signal sync_progress(current, total)
signal sync_finished
signal sync_error(msg)
signal status_changed(status_text)

enum SyncState { IDLE, CHECKING, SYNCING, OFFLINE }

var _state: SyncState = SyncState.IDLE
var _queue: Array = []
var _current_upload_index: int = 0
var _http: HTTPRequest
var _check_timer: Timer
var _base_url: String = "https://api.example.com" # Placeholder, will be loaded from config

func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_upload_completed)
	
	_check_timer = Timer.new()
	add_child(_check_timer)
	_check_timer.wait_time = 10.0 # Check every 10 seconds
	_check_timer.timeout.connect(_check_for_unsynced_files)
	_check_timer.start()
	
	_load_config()
	
	# Initial check after a short delay
	get_tree().create_timer(2.0).timeout.connect(_check_for_unsynced_files)

func _load_config() -> void:
	var config_path := "res://shared/config/endpoints.json"
	if ResourceLoader.exists(config_path):
		var f := FileAccess.open(config_path, FileAccess.READ)
		if f:
			var txt := f.get_as_text()
			var data = JSON.parse_string(txt)
			if data and "api_base_url" in data:
				_base_url = data["api_base_url"]

func _check_for_unsynced_files() -> void:
	_check_processing_projects()
	
	if _state == SyncState.SYNCING:
		return
		
	if not Auth.is_authenticated():
		_set_status("Aguardando login...")
		return

	# Simple connectivity check could be added here, but for now we assume if we have a token we might be online
	# or we'll fail on the first request.
	
	_state = SyncState.CHECKING
	_queue.clear()
	
	var captures_dir := "user://captures"
	if not DirAccess.dir_exists_absolute(captures_dir):
		_state = SyncState.IDLE
		return
		
	var dir := DirAccess.open(captures_dir)
	if dir:
		dir.list_dir_begin()
		var session_name := dir.get_next()
		while session_name != "":
			if dir.current_is_dir() and not session_name.begins_with("."):
				_scan_session(captures_dir + "/" + session_name)
			session_name = dir.get_next()
		dir.list_dir_end()
	
	if _queue.size() > 0:
		_start_sync()
	else:
		_state = SyncState.IDLE
		_set_status("Sincronizado")

func _scan_session(session_path: String) -> void:
	# Check if capture is complete (.ready exists) and not yet synced
	var ready_marker = session_path + "/.ready"
	var synced_marker = session_path + "/.synced"
	
	if FileAccess.file_exists(ready_marker) and not FileAccess.file_exists(synced_marker):
		var meta_path = session_path + "/metadata.json"
		if FileAccess.file_exists(meta_path):
			_queue.append({
				"meta": meta_path,
				"marker": synced_marker,
				"session": session_path.get_file(),
				"session_path": session_path
			})

func _start_sync() -> void:
	_state = SyncState.SYNCING
	_current_upload_index = 0
	emit_signal("sync_started")
	_set_status("Sincronizando...")
	_upload_next()

func _upload_next() -> void:
	if _current_upload_index >= _queue.size():
		_finish_sync()
		return
		
	var item = _queue[_current_upload_index]
	emit_signal("sync_progress", _current_upload_index + 1, _queue.size())
	
	ProjectManager.update_project_status(item["session"], "uploading")
	
	var zip_path = item["session_path"] + "/upload.zip"
	if not FileAccess.file_exists(zip_path):
		var packer := ZIPPacker.new()
		var err = packer.open(zip_path)
		if err == OK:
			packer.start_file("metadata.json")
			packer.write_file(FileAccess.get_file_as_bytes(item["meta"]))
			packer.close_file()
			
			var frames_dir = item["session_path"] + "/frames"
			var dir = DirAccess.open(frames_dir)
			if dir:
				dir.list_dir_begin()
				var file_name = dir.get_next()
				while file_name != "":
					if not dir.current_is_dir() and file_name.ends_with(".png"):
						packer.start_file("frames/" + file_name)
						packer.write_file(FileAccess.get_file_as_bytes(frames_dir + "/" + file_name))
						packer.close_file()
					file_name = dir.get_next()
				dir.list_dir_end()
			packer.close()
			
	if not FileAccess.file_exists(zip_path):
		_handle_error("Falha ao criar ZIP")
		return
		
	var zip_bytes = FileAccess.get_file_as_bytes(zip_path)
	var headers = [
		"Content-Type: application/zip",
		"X-Session-ID: " + item["session"],
		"Authorization: Bearer " + Auth.token()
	]
	
	var url = _base_url + "/upload_session_zip" 
	var err = _http.request_raw(url, headers, HTTPClient.METHOD_POST, zip_bytes)
	if err != OK:
		_handle_error("Erro ao iniciar request: " + str(err))

func _on_upload_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		var msg = "Erro HTTP: " + str(response_code)
		_handle_error(msg)
		# Retry logic could be added here, for now we skip or stop
		# To be safe, we stop sync on error to avoid spamming
		_state = SyncState.IDLE
		_set_status("Erro na sincronização")
		emit_signal("sync_error", msg)
		return
		
	# Success
	var item = _queue[_current_upload_index]
	var f = FileAccess.open(item["marker"], FileAccess.WRITE)
	if f:
		f.store_string("synced")
		f.close()
	
	ProjectManager.update_project_status(item["session"], "processing")
	
	_current_upload_index += 1
	_upload_next()

func _finish_sync() -> void:
	_state = SyncState.IDLE
	_queue.clear()
	emit_signal("sync_finished")
	_set_status("Sincronizado")

func _handle_error(msg: String) -> void:
	print_debug("Sync Error: " + msg)
	# Don't stop everything forever, just this batch
	_state = SyncState.IDLE

func _set_status(text: String) -> void:
	emit_signal("status_changed", text)

func _check_processing_projects() -> void:
	if not Auth.is_authenticated():
		return
	
	for p in ProjectManager.get_projects():
		if p.get("status") == "processing":
			_check_project_status(p["id"])

func _check_project_status(session_id: String) -> void:
	var url = _base_url + "/status/" + session_id
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(result: int, code: int, headers: PackedStringArray, body: PackedByteArray):
		if result == HTTPRequest.RESULT_SUCCESS and code == 200:
			var txt = body.get_string_from_utf8()
			var data = JSON.parse_string(txt)
			if data and typeof(data) == TYPE_DICTIONARY:
				if data.get("status") == "ready" and data.has("ply_url"):
					_download_ply(session_id, data.get("ply_url"))
		http.queue_free()
	)
	var headers = ["Authorization: Bearer " + Auth.token()]
	http.request(url, headers)

func _download_ply(session_id: String, ply_url: String) -> void:
	ProjectManager.update_project_status(session_id, "downloading")
	var url = ply_url
	var http = HTTPRequest.new()
	add_child(http)
	
	var models_dir = "user://models"
	if not DirAccess.dir_exists_absolute(models_dir):
		DirAccess.make_dir_recursive_absolute(models_dir)
		
	var download_path = models_dir + "/" + session_id + ".ply"
	http.download_file = download_path
	
	http.request_completed.connect(func(result: int, code: int, headers: PackedStringArray, body: PackedByteArray):
		if result == HTTPRequest.RESULT_SUCCESS and code < 300:
			var p = ProjectManager.get_project(session_id)
			if not p.is_empty():
				p["status"] = "ready_to_view"
				p["ply_local_path"] = download_path
				p["ply_url"] = ply_url
				ProjectManager.save_projects()
				ProjectManager.emit_signal("projects_updated")
				_set_status("Splat pronto: " + session_id)
		else:
			ProjectManager.update_project_status(session_id, "processing") # back to processing to retry later
		http.queue_free()
	)
	
	var headers = ["Authorization: Bearer " + Auth.token()]
	http.request(url, headers)
