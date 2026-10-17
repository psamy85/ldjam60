extends Node2D

@export var line_path: NodePath
@onready var line: Line2D = get_node(line_path)

@export var player_path: NodePath 
@onready var player: Player = get_node(player_path)

@export_group("Amplitude")
@export var amplitude: float = 30.0
@export var min_amplitude: float = 30.0
@export var max_amplitude: float = 500.0
@export var amplitude_speed: float = 60.0   

@export_group("Largeur des vagues")
@export var wavelength: float = 300.0          # distance crête à crête, en pixels
@export var min_wavelength: float = 80.0
@export var max_wavelength: float = 800.0
@export var wavelength_speed: float = 200.0    # variation en pixels/s quand on appuie
@export var wavelength_smoothing: float = 8.0  # plus grand = plus réactif

@export_group("Tracé")
@export var preview_points: int = 300
@export var edge_margin: float = 50.0   

@export_group("Défilement")
@export var scroll_speed: float = 3.0
@export var scroll_accel: float = 6.0

var phase: float = 0.0
var current_scroll: float = 0.0
var target_wavelength: float

func _ready() -> void:
	line.position = get_viewport_rect().size / 2
	current_scroll = scroll_speed * player.direction.x   # démarre déjà à pleine vitesse
	target_wavelength = wavelength
	draw_trajectory()

func _process(delta: float) -> void:
	update_phase(delta)
	change_trajectory(delta)
	update_wavelength(delta)
	draw_trajectory()
	update_player()
	
func update_phase(delta: float) -> void:
	# On suit la direction du joueur, avec un demi-tour progressif
	var target_scroll: float = scroll_speed * player.direction.x
	current_scroll = move_toward(current_scroll, target_scroll, scroll_accel * delta)
	# On change la vitesse d'accumulation, jamais la valeur de phase elle-même
	phase += current_scroll * delta
	
	
func change_trajectory(delta: float) -> void:
	var input_y := Input.get_axis("lower", "higher")
	amplitude = clampf(amplitude + input_y * amplitude_speed * delta, min_amplitude, max_amplitude)

	# Les touches ne changent que la cible, le lissage se fait dans update_wavelength
	var input_w := Input.get_axis("narrower", "wider")
	target_wavelength = clampf(target_wavelength + input_w * wavelength_speed * delta, min_wavelength, max_wavelength)

func update_wavelength(delta: float) -> void:
	var old_k: float = TAU / wavelength
	# Lissage indépendant du framerate
	wavelength = lerpf(wavelength, target_wavelength, 1.0 - exp(-wavelength_smoothing * delta))
	var new_k: float = TAU / wavelength

	# Compense la phase pour que la vague ne bouge pas sous le joueur pendant l'étirement
	var player_x: float = line.to_local(player.global_position).x
	phase += player_x * (old_k - new_k)

# La courbe est maintenant fonction de x en pixels, plus de t
func wave_y(x: float) -> float:
	return sin(x * TAU / wavelength + phase) * amplitude

func draw_trajectory() -> void:
	if not line:
		return
	line.clear_points()
	# La ligne couvre toujours tout l'écran (plus une marge), quelle que soit la largeur des vagues
	var half_width: float = get_viewport_rect().size.x * 0.5 + edge_margin
	for i in range(preview_points):
		var x: float = lerpf(-half_width, half_width, float(i) / (preview_points - 1))
		line.add_point(Vector2(x, wave_y(x)))

func update_player() -> void:
	if not line or not player:
		return
	var local_pos: Vector2 = line.to_local(player.global_position)
	local_pos.y = wave_y(local_pos.x)
	player.global_position = line.to_global(local_pos)
