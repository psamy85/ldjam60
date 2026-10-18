class_name Collectible
extends Area2D

@export var hitbox_padding: Vector2 = Vector2(4, 4) 

@onready var collision: CollisionShape2D = %CollisionShape2D
@onready var label: Label = %Label
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D

signal collected(data: CollectibleData)

var data: CollectibleData
var speed := 120.0
var direction := Vector2.ZERO
var points: int = 10

func _ready() -> void:
	visible_on_screen_notifier_2d.screen_exited.connect(_on_screen_exited)
	area_entered.connect(_on_area_entered)
	if data == null:
		push_warning("%s n'a pas de data, supprimé." % name)
		queue_free()
		return
	
	if data.random_points:
		var steps: int = randi_range(data.min_points / data.points_step, data.max_points / data.points_step)
		points = steps * data.points_step
		label.text = format_hz(points)
	else:
		points = data.points
		label.text = data.display_text
		
	if data.is_bonus:
		label.modulate = data.color.lerp(Color.WHITE, float(points) / data.max_points)

	label.modulate = data.color
	fit_collision_to_label()   # après le texte, pour que la hitbox suive la longueur du nombre
	area_entered.connect(_on_area_entered)
	
	var random_scale : float = randf_range(2.0, 3.0)
	scale = Vector2(random_scale, random_scale)

func _process(delta: float) -> void:
	position += direction * speed * delta

func _on_screen_exited() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		collected.emit(data, points)
		queue_free()

func fit_collision_to_label() -> void:
	# Ramène le Label à la taille exacte de son texte
	label.size = label.get_minimum_size()
	var visual_size: Vector2 = label.size * label.scale

	label.position = -visual_size / 2.0

	var rect := RectangleShape2D.new()
	rect.size = visual_size + hitbox_padding * 2.0
	collision.shape = rect
	collision.position = Vector2.ZERO

func format_hz(value: int) -> String:
	if value >= 1000 and value % 1000 == 0:
		return "%dkHz" % (value / 1000)
	return "%dHz" % value
