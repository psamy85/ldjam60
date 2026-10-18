extends Control

@export var line_color: Color = Color(0.3, 1.0, 0.4)
@export var line_width: float = 2.0
@export var glow_width: float = 8.0
@export_range(0.0, 1.0) var glow_alpha: float = 0.25
@export_range(0.0, 0.5) var amplitude_ratio: float = 0.3   # hauteur de la vague, en fraction de l'écran
@export var wave_count: float = 2.0                        # nombre de vagues visibles
@export var scroll_speed: float = 3.0
@export var points: int = 120
@export var margin: float = 8.0                            # espace sur les bords gauche et droit

var phase: float = 0.0

func _process(delta: float) -> void:
	phase += scroll_speed * delta
	queue_redraw()   # redemande un _draw() à chaque frame

func _draw() -> void:
	var pts := PackedVector2Array()
	var width: float = size.x - margin * 2.0
	var center_y: float = size.y / 2.0
	var amp: float = size.y * amplitude_ratio

	for i in range(points):
		var r: float = float(i) / (points - 1)      # de 0 à 1 sur la largeur
		var x: float = margin + r * width
		var y: float = center_y + sin(r * wave_count * TAU + phase) * amp
		pts.append(Vector2(x, y))

	# Halo large et transparent, puis trait fin par-dessus : effet phosphore
	draw_polyline(pts, Color(line_color, glow_alpha), glow_width, true)
	draw_polyline(pts, line_color, line_width, true)
