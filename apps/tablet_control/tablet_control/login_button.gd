extends Button

func _ready() -> void:
    Auth.logged_in.connect(_on_logged_in)
    Auth.login_failed.connect(_on_login_failed)
    pressed.connect(_on_pressed)

func _on_pressed() -> void:
    var email := $"../Email".text
    var password := $"../Password".text
    Auth.login(email, password)

func _on_logged_in() -> void:
    # Após login, navegue para tela principal do Tablet
    get_tree().change_scene_to_file("res://tablet_control/control.tscn")

func _on_login_failed(error) -> void:
    $"../ErrorLabel".text = "Falha no login: %s" % error