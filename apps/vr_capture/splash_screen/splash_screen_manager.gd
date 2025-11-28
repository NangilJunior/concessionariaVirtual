extends Control

@export var _move_to: PackedScene

#@export var _initial_delay: float = 1

var _splash_screens: Array[SplashScreen] = []

@onready var _splash_screen_container: CenterContainer = $SplashScreenContainer


func _ready() -> void:
	assert(_move_to, "Move to scene not set!")
	print("[SplashScreenManager] Ready - Move to: ", _move_to.resource_path if _move_to else "NULL")
	
	for splash_screen in _splash_screen_container.get_children():
		splash_screen.hide()
		_splash_screens.push_back(splash_screen)
		
#		await get_tree().create_timer(_initial_delay).timeout
		
	print("[SplashScreenManager] Found ", _splash_screens.size(), " splash screens")
	_start_splash_screen()
	
	
func _start_splash_screen() -> void:
	print("[SplashScreenManager] Starting next splash screen. Remaining: ", _splash_screens.size())
	if _splash_screens.size() == 0:
		print("[SplashScreenManager] All splash screens done. Changing to: ", _move_to.resource_path)
		get_tree().change_scene_to_packed(_move_to)
	else:
		var splash_screen: SplashScreen = _splash_screens.pop_front()
		print("[SplashScreenManager] Starting splash: ", splash_screen.name)
		splash_screen.start()
		splash_screen.finished.connect(_start_splash_screen)

