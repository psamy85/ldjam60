class_name CollectibleData
extends Resource

@export_multiline var description: String = ""
@export var display_text: String = "+"
@export var color: Color = Color.WHITE
@export var is_bonus: bool = true
@export var duration: float = 0.0       # 0 = permanent, remove() n'est pas appelé
@export var spawn_weight: float = 1.0
@export var points: int = 10

@export_group("Points aléatoires")
@export var random_points: bool = false
@export var min_points: int = 10
@export var max_points: int = 100
@export var points_step: int = 10

func apply(_player: Player, _wave: Wave) -> void:
	pass

func remove(_player: Player, _wave: Wave) -> void:
	pass
