extends Control

@export_file("*.tscn") var game_scene: String = "res://scenes/main.tscn"

@onready var play_button: Button = %PlayButton
@onready var quit_button: Button = %QuitButton
@onready var best_label: Label = %BestLabel
@onready var tutorial_button: Button = %TutorialButton
@onready var tuto: Control = %Tuto

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	best_label.visible = GameState.best_score > 0
	best_label.text = "BEST SCORE\n%06d" % GameState.best_score
	tutorial_button.pressed.connect(tuto.show)
	
	quit_button.visible = not OS.has_feature("web")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(game_scene)

func _on_quit_pressed() -> void:
	get_tree().quit()
