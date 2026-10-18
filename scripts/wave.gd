class_name Wave
extends Line2D

@export var player: Player

@export_group("Amplitude")
@export var amplitude: float = 120.0
@export var min_amplitude: float = 30.0
@export var max_amplitude: float = 320.0
@export var amplitude_speed: float = 60.0

@export_group("Largeur des vagues")
@export var wavelength: float = 300.0
@export var min_wavelength: float = 80.0
@export var max_wavelength: float = 800.0
@export var wavelength_speed: float = 200.0
@export var wavelength_smoothing: float = 8.0

@export_group("Tracé")
@export var preview_points: int = 300
@export var edge_margin: float = 50.0

@export_group("Défilement")
@export var scroll_speed: float = 3.0
@export var scroll_accel: float = 6.0

var phase: float = 0.0
var current_scroll: float = 0.0
var target_wavelength: float
var scroll_frozen: int = 0
var is_active : bool = true
var amplitude_scale: float = 1.0
var wavelength_scale: float = 1.0 
var noise_amount: float = 0.0  
var difficulty_scroll: float = 0.0

func _ready() -> void:
	position = get_viewport_rect().size / 2
	current_scroll = scroll_speed * player.direction.x
	target_wavelength = wavelength
	draw_trajectory()

func _process(delta: float) -> void:
	if is_active:
		update_phase(delta)
		change_trajectory(delta)
		update_wavelength(delta)
		update_player()
	else :
		phase += current_scroll * delta
	draw_trajectory()

func update_phase(delta: float) -> void:
	if not player:
		return
	var target_scroll: float = 0.0 if scroll_frozen > 0 else (scroll_speed + difficulty_scroll) * player.direction.x
	current_scroll = move_toward(current_scroll, target_scroll, scroll_accel * delta)
	phase += current_scroll * delta

func change_trajectory(delta: float) -> void:
	var input_y := Input.get_axis("lower", "higher")
	amplitude = clampf(amplitude + input_y * amplitude_speed * delta, min_amplitude, max_amplitude)

	var input_w := Input.get_axis("narrower", "wider")
	target_wavelength = clampf(target_wavelength + input_w * wavelength_speed * delta, min_wavelength, max_wavelength)

func update_wavelength(delta: float) -> void:
	if not player:
		return
	var old_k: float = TAU / wavelength
	wavelength = lerpf(wavelength, target_wavelength * maxf(wavelength_scale, 0.1), 1.0 - exp(-wavelength_smoothing * delta))
	var new_k: float = TAU / wavelength

	var player_x: float = to_local(player.global_position).x
	phase += player_x * (old_k - new_k)

func wave_y(x: float) -> float:
	var y: float = sin(x * TAU / wavelength + phase) * amplitude * maxf(amplitude_scale, 0.0)
	if noise_amount > 0.0:
		y += randf_range(-noise_amount, noise_amount)
	return y

func draw_trajectory() -> void:
	clear_points()
	var half_width: float = get_viewport_rect().size.x * 0.5 + edge_margin
	for i in range(preview_points):
		var x: float = lerpf(-half_width, half_width, float(i) / (preview_points - 1))
		add_point(Vector2(x, wave_y(x)))

func update_player() -> void:
	if not player:
		return
	var local_pos: Vector2 = to_local(player.global_position)
	local_pos.y = wave_y(local_pos.x)
	player.global_position = to_global(local_pos)

func flatten_game_over(duration: float = 0.8) -> void:
	is_active = false
	var tween := create_tween()
	tween.tween_property(self, "amplitude", 0.0, duration) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "current_scroll", 0.0, duration)
