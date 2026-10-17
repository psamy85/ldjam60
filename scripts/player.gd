extends Area2D
class_name Player

@onready var boost_timer: Timer = %BoostTimer

var INIT_SPEED := 120.0
var BOOST_SPEED := INIT_SPEED * 4

var direction := Vector2.RIGHT
var is_boosting := false

func _ready() -> void:
	boost_timer.one_shot = true
	boost_timer.timeout.connect(_on_boost_timeout)
	position.x = get_viewport_rect().size.x / 2

func _process(delta: float) -> void:
	# Déclenchement du boost (une seule fois par appui)
	if Input.is_action_just_pressed("boost") and not is_boosting:
		is_boosting = true
		boost_timer.start()

	# Pendant le boost : on fonce dans la dernière direction, sans lire les touches
	if is_boosting:
		var input_x := Input.get_axis("left", "right")
		if input_x != 0.0:
			direction = Vector2(signf(input_x), 0)
		position.x += direction.x * BOOST_SPEED * delta
		return

	# Déplacement normal
	var input_x := Input.get_axis("left", "right")   # -1, 0 ou 1 (analogique à la manette)
	if input_x != 0.0:
		direction = Vector2(signf(input_x), 0)       # on mémorise la dernière direction
		position.x += input_x * INIT_SPEED * delta
	
func _on_boost_timeout() -> void:
	is_boosting = false
