class_name Player
extends Area2D

@onready var boost_timer: Timer = %BoostTimer

signal health_changed(health: int, max_health: int)
signal died

var move_speed := 120.0
var BOOST_SPEED := move_speed * 4

var direction := Vector2.RIGHT
var is_boosting : bool = false
var inverted_controls: int = 0

var fuses: int = 0
var max_health : int = 5
var health: int:
	set(value):
		if value < health and fuses > 0:
			fuses -= 1
			return
		health = clampi(int(value), 0, max_health)
		health_changed.emit(health, max_health)
		if health <= 0:
			died.emit()


func _ready() -> void:
	health = max_health
	boost_timer.one_shot = true
	boost_timer.timeout.connect(_on_boost_timeout)
	position.x = get_viewport_rect().size.x / 2

func _process(delta: float) -> void:
	# Déclenchement du boost (une seule fois par appui)
	if Input.is_action_just_pressed("boost") and not is_boosting:
		is_boosting = true
		boost_timer.start()
		
	var input_x := Input.get_axis("left", "right")
	if inverted_controls > 0:
		input_x = -input_x
		
	if input_x != 0.0:
		direction = Vector2(signf(input_x), 0)  # on mémorise la dernière direction

	# Pendant le boost : on fonce dans la dernière direction, même si on avance pas
	if is_boosting:
		position.x += direction.x * BOOST_SPEED * delta
	elif input_x != 0.0:
		position.x += input_x * move_speed * delta
		
	var screen_width: float = get_viewport_rect().size.x
	position.x = wrapf(position.x, 80.0, screen_width - 80.0)
	
func _on_boost_timeout() -> void:
	is_boosting = false
