extends Control

@onready var _back_btn: ClickableCard = $MarginContainer2/HBoxContainer/VBoxContainer/HBoxContainer2/BacktButton

func _ready() -> void:
	_back_btn.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://home/home_screen.tscn")
