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
	# Check if session is fully synced (e.g. check for a .synced file or check all frames)
	# For this implementation, we check individual frames that don't have a corresponding .synced marker
	
	var dir := DirAccess.open(session_path)
	if not dir: return
	
	# We look for metadata_*.json files
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.begins_with("metadata_") and file_name.ends_with(".json"):
			var frame_index_str = file_name.trim_prefix("metadata_").trim_suffix(".json")
			var synced_marker = session_path + "/frame_" + frame_index_str + ".synced"
			
			if not FileAccess.file_exists(synced_marker):
				var image_path = session_path + "/frame_" + frame_index_str + ".png"
				var meta_path = session_path + "/" + file_name
				
				if FileAccess.file_exists(image_path):
					_queue.append({
						"image": image_path,
						"meta": meta_path,
						"marker": synced_marker,
						"session": session_path.get_file()
					})
		file_name = dir.get_next()
	dir.list_dir_end()

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
	
	# Construct multipart request or simple JSON with base64
	# For simplicity and robustness in Godot without plugins, we'll try to send JSON with Base64 image
	# If the server requires multipart, we'd need to build the body manually with boundaries.
	# Let's assume the server accepts a JSON payload with metadata and image_data.
	
	var meta_content = FileAccess.get_file_as_string(item["meta"])
	var meta_json = JSON.parse_string(meta_content)
	
	var img_file = FileAccess.open(item["image"], FileAccess.READ)
	var img_buffer = img_file.get_buffer(img_file.get_length())
	var img_b64 = Marshalls.raw_to_base64(img_buffer)
	
	var payload = {
		"session_id": item["session"],
		"metadata": meta_json,
		"image_data": img_b64
	}
	
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Auth.token()
	]
	
	var url = _base_url + "/upload" # Adjust endpoint as needed
	
	var err = _http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if err != OK:
		_handle_error("Erro ao iniciar request: " + str(err))

func _on_upload_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
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
	f.store_string("synced")
	f.close()
	
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
