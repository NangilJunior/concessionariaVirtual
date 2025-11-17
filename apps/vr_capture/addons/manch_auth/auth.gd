extends Node
# Removido: class_name Auth (para não conflitar com o Autoload "Auth")

signal logged_in
signal logged_out
signal login_failed(error)

var _http: HTTPRequest
var _config: Dictionary
var _token: String = ""
var _refresh_token: String = ""

func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_load_config()
	_load_tokens()

func _load_config() -> void:
	var config_path := "res://shared/config/endpoints.json"
	if ResourceLoader.exists(config_path):
		var f := FileAccess.open(config_path, FileAccess.READ)
		if f:
			var txt := f.get_as_text()
			_config = JSON.parse_string(txt) if txt != "" else {}
	else:
		_config = {}

func _save_tokens() -> void:
	var f := FileAccess.open("user://auth.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"token": _token, "refresh_token": _refresh_token}))

func _load_tokens() -> void:
	if FileAccess.file_exists("user://auth.json"):
		var f := FileAccess.open("user://auth.json", FileAccess.READ)
		var txt := f.get_as_text()
		var data := JSON.parse_string(txt)
		if typeof(data) == TYPE_DICTIONARY:
			_token = data.get("token", "")
			_refresh_token = data.get("refresh_token", "")

func is_authenticated() -> bool:
	return _token != ""

func token() -> String:
	return _token

func logout() -> void:
	_token = ""
	_refresh_token = ""
	_save_tokens()
	emit_signal("logged_out")

func login(email: String, password: String) -> void:
	var base := _config.get("admin_base_url", "")
	var path := _config.get("auth_login_path", "/auth/login")
	var url := "%s%s" % [base, path]
	var payload := {"email": email, "password": password}
	var headers := ["Content-Type: application/json"]

	_http.request_completed.connect(_on_login_completed)
	var err := _http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if err != OK:
		emit_signal("login_failed", "request_error_%s" % err)

func _on_login_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	# Desconecta para evitar múltiplas conexões
	if _http.request_completed.is_connected(_on_login_completed):
		_http.request_completed.disconnect(_on_login_completed)

	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		emit_signal("login_failed", "http_%s" % response_code)
		return

	var txt := body.get_string_from_utf8()
	var data := JSON.parse_string(txt)
	if typeof(data) != TYPE_DICTIONARY:
		emit_signal("login_failed", "invalid_json")
		return

	_token = data.get("token", "")
	_refresh_token = data.get("refresh_token", "")
	_save_tokens()
	emit_signal("logged_in")

func refresh() -> void:
	if _refresh_token == "":
		emit_signal("login_failed", "no_refresh_token")
		return

	var base := _config.get("admin_base_url", "")
	var path := _config.get("auth_refresh_path", "/auth/refresh")
	var url := "%s%s" % [base, path]
	var payload := {"refresh_token": _refresh_token}
	var headers := ["Content-Type: application/json"]

	_http.request_completed.connect(_on_refresh_completed)
	var err := _http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if err != OK:
		emit_signal("login_failed", "request_error_%s" % err)

func _on_refresh_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if _http.request_completed.is_connected(_on_refresh_completed):
		_http.request_completed.disconnect(_on_refresh_completed)

	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		emit_signal("login_failed", "http_%s" % response_code)
		return

	var txt := body.get_string_from_utf8()
	var data := JSON.parse_string(txt)
	if typeof(data) != TYPE_DICTIONARY:
		emit_signal("login_failed", "invalid_json")
		return

	_token = data.get("token", _token)
	_refresh_token = data.get("refresh_token", _refresh_token)
	_save_tokens()
	emit_signal("logged_in")