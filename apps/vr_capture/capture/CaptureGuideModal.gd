extends Control

signal step_started(step_index)
signal step_completed(step_index)
signal capture_finished

enum Step {
	MAPPING = 0,
	CAPTURE = 1,
	DETAILING = 2
}

var _current_step: int = Step.MAPPING
var _is_minimized: bool = false
var _has_started_step: bool = false

# UI Nodes (to be linked in the scene)
@onready var _full_mode: Control = %FullMode
@onready var _minimized_mode: Control = %MinimizedMode
@onready var _title_label: Label = %TitleLabel
@onready var _desc_label: Label = %DescLabel
@onready var _action_btn: Button = %ActionButton
@onready var _minimize_btn: Button = %MinimizeButton
@onready var _restore_btn: Button = %RestoreButton

# Step Layers (TextureRects)
# Note: Using get_node because names have spaces "Step 1", etc.
@onready var _step1_layer: Control = _full_mode.find_child("Step 1", true, false)
@onready var _step2_layer: Control = _full_mode.find_child("Step 2", true, false)
@onready var _step3_layer: Control = _full_mode.find_child("Step 3", true, false)

# Step Data
var _steps_data = {
	Step.MAPPING: {
		"title": "Mapeamento",
		"desc": "Realize o mapeamento da área de interesse ou do produto que será digitalizado.",
		"action_text": "Próxima"
	},
	Step.CAPTURE: {
		"title": "Captura",
		"desc": "Realize a captura (escaneamento) completa do ambiente ou produto mapeado.",
		"action_text": "Próxima"
	},
	Step.DETAILING: {
		"title": "Detalhamento",
		"desc": "Faça o detalhamento aproximando a câmera de áreas com mais detalhes.",
		"action_text": "Finalizar"
	}
}

func _ready() -> void:
	_minimize_btn.pressed.connect(_on_minimize_pressed)
	_restore_btn.pressed.connect(_on_restore_pressed)
	_action_btn.pressed.connect(_on_action_pressed)
	
	# Initialize
	_update_ui()

func _update_ui() -> void:
	var data = _steps_data[_current_step]
	_title_label.text = data["title"]
	_desc_label.text = data["desc"]
	_action_btn.text = data["action_text"]
	
	_full_mode.visible = not _is_minimized
	_minimized_mode.visible = _is_minimized
	
	# Button Visibility Logic
	# "Iniciar" (Minimize) is visible ONLY if step has NOT started
	# "Próxima" (Action) is visible ONLY if step HAS started
	_minimize_btn.visible = not _has_started_step
	_action_btn.visible = _has_started_step
	
	# Update Step Layers
	if _step1_layer: _step1_layer.visible = (_current_step == Step.MAPPING)
	if _step2_layer: _step2_layer.visible = (_current_step == Step.CAPTURE)
	if _step3_layer: _step3_layer.visible = (_current_step == Step.DETAILING)

func _on_minimize_pressed() -> void:
	_is_minimized = true
	_has_started_step = true # Mark as started so Next button appears on restore
	_update_ui()
	emit_signal("step_started", _current_step)

func _on_restore_pressed() -> void:
	_is_minimized = false
	_update_ui()

func _on_action_pressed() -> void:
	emit_signal("step_completed", _current_step)
	
	if _current_step < Step.DETAILING:
		_current_step += 1
		_is_minimized = false # Auto-restore on next step
		_has_started_step = false # Reset for next step
		_update_ui()
	else:
		emit_signal("capture_finished")
		# Hide or close modal? For now just stay or hide
		visible = false
