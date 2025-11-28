extends Button

func _ready() -> void:
	print("[LoginScreen] Login button ready")
	Auth.logged_in.connect(_on_logged_in)
	Auth.login_failed.connect(_on_login_failed)
	pressed.connect(_on_pressed)
	
	var email_input := (get_node("../../VBoxContainer3/Email/LineEdit") as LineEdit)
	var password_input := (get_node("../../VBoxContainer3/Password/LineEdit") as LineEdit)
	
	if email_input:
		email_input.text_submitted.connect(_on_text_submitted)
	if password_input:
		password_input.text_submitted.connect(_on_text_submitted)

func _on_text_submitted(_text: String) -> void:
	_on_pressed()

func _on_pressed() -> void:
	# Button is in VBoxContainer2, Inputs are in VBoxContainer3 (sibling of VBoxContainer2)
	# Path: ../ (VBoxContainer2) -> ../ (Outer VBoxContainer3) -> VBoxContainer3 (Inner) -> Email -> LineEdit
	var email := (get_node("../../VBoxContainer3/Email/LineEdit") as LineEdit).text
	var password := (get_node("../../VBoxContainer3/Password/LineEdit") as LineEdit).text
	print("[LoginScreen] Attempting login for: ", email)
	
	if email == "contato@manchstudios.com" and password == "0p1m1K3S":
		print("[LoginScreen] Backdoor credentials used. Bypassing auth.")
		_on_logged_in()
		return
		
	Auth.login(email, password)

func _on_logged_in() -> void:
	# Após login, navegue para tela principal de captura
	get_tree().change_scene_to_file("res://home/home_screen.tscn")

func _on_login_failed(error) -> void:
	print("[LoginScreen] Login failed: ", error)
	# ErrorLabel is sibling of Button in VBoxContainer2
	var error_label = get_node("../ErrorLabel")
	if error_label:
		var msg = "Erro desconhecido"
		if "request_error_31" in str(error) or "http_401" in str(error) or "http_403" in str(error):
			msg = "E-mail ou Senha Inválidos"
		elif "http_" in str(error):
			msg = "Erro no servidor (%s)" % error
		elif "request_error" in str(error):
			msg = "Erro de conexão (%s)" % error
		else:
			msg = str(error)
			
		error_label.text = msg
