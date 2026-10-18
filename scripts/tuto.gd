extends Control

@export_file("*.tscn") var menu_scene: String = "res://scenes/menu.tscn"
@export var font_size: int = 24
@export var key_color: Color = Color(0.3, 1.0, 0.4)

# Actions à afficher : "action1|action2" regroupe plusieurs actions sur une ligne
@export var controls: Dictionary = {
	"left|right": "Move",
	"lower|higher": "Wave height",
	"narrower|wider": "Wave width",
	"ui_cancel": "Pause / lexicon",
}

@onready var controls_grid: GridContainer = %ControlsGrid
@onready var back_button: Button = %BackButton

func _ready() -> void:
	hide()   # caché au lancement du menu
	back_button.pressed.connect(hide)
	build_controls()

func build_controls() -> void:
	for actions in controls:
		print(actions, " → ", actions.split("|"), " existe : ", InputMap.has_action(actions.split("|")[0]))
		var keys: Array[String] = []
		for action in actions.split("|"):
			keys.append_array(_keys_for_action(action))
		if keys.is_empty():
			continue
		_add_row(keys, controls[actions])

# Renvoie les touches clavier associées à une action, selon la disposition du joueur
func _keys_for_action(action: String) -> Array[String]:
	var result: Array[String] = []
	if not InputMap.has_action(action):
		push_warning("Action introuvable : %s" % action)
		return result
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var code: Key = event.keycode
			if event.physical_keycode != 0:
				code = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
			result.append(OS.get_keycode_string(code))
		elif event is InputEventMouseButton:
			result.append(_mouse_button_name(event.button_index))
	return result

func _mouse_button_name(index: MouseButton) -> String:
	match index:
		MOUSE_BUTTON_LEFT: return "Left click"
		MOUSE_BUTTON_RIGHT: return "Right click"
	return "Mouse %d" % index

func _add_row(keys: Array[String], description: String) -> void:
	var keys_label := Label.new()
	keys_label.text = " / ".join(keys)
	keys_label.modulate = key_color
	keys_label.add_theme_font_size_override("font_size", font_size)
	controls_grid.add_child(keys_label)

	var desc_label := Label.new()
	desc_label.text = description
	desc_label.add_theme_font_size_override("font_size", font_size)
	controls_grid.add_child(desc_label)

# Échap ferme aussi le panneau
func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("pause"):
		hide()
		get_viewport().set_input_as_handled()
