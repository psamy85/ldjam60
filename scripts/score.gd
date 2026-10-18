class_name Score
extends Node

signal score_changed(score: int)
signal combo_changed(combo: int, multiplier: int)

@export var combo_window: float = 5.0  
@export var max_multiplier: int = 10

var score: int = 0
var combo: int = 0

var _combo_timer := Timer.new()

func _ready() -> void:
	_combo_timer.one_shot = true
	_combo_timer.timeout.connect(_break_combo)
	add_child(_combo_timer)

func get_multiplier() -> int:
	return clampi(combo, 1, max_multiplier)

func register(data: CollectibleData, points: int) -> void:
	if data.is_bonus:
		combo += 1
		_combo_timer.start(combo_window)   # relance le chrono du combo
		score += points * get_multiplier()
		score_changed.emit(score)
		combo_changed.emit(combo, get_multiplier())
	else:
		_break_combo()

func _break_combo() -> void:
	combo = 0
	_combo_timer.stop()
	combo_changed.emit(combo, get_multiplier())
