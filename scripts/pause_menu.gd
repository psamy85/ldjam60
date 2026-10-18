extends Control

var can_pause: bool = true

@onready var grid: GridContainer = %LexiconGrid
@export var lexicon_font_size: int = 24

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and can_pause:
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	visible = get_tree().paused

func build_lexicon(entries: Array[CollectibleData]) -> void:
	for child in grid.get_children():
		child.queue_free()

	var sorted: Array[CollectibleData] = entries.duplicate()
	sorted.sort_custom(func(a, b): return a.is_bonus and not b.is_bonus)

	for data in sorted:
		if data.description.strip_edges().is_empty():
			continue
		var name_label := Label.new()
		name_label.text = data.display_text
		name_label.modulate = data.color
		name_label.add_theme_font_size_override("font_size", lexicon_font_size)
		grid.add_child(name_label)

		var desc_label := Label.new()
		desc_label.text = data.description
		desc_label.add_theme_font_size_override("font_size", lexicon_font_size)
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.custom_minimum_size.x = 320
		grid.add_child(desc_label)
