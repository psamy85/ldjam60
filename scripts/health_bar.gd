class_name HealthBlocks
extends HBoxContainer

@export var full_color: Color = Color(0.3, 1.0, 0.4)
@export var empty_color: Color = Color(0.08, 0.2, 0.1)
@export var low_color: Color = Color(1.0, 0.3, 0.3)
@export var low_health: int = 1  

func set_health(health: int, _max_health: int) -> void:
	var blocks: Array = get_children().filter(func(child): return child is ColorRect)
	var color: Color = low_color if health <= low_health else full_color

	for i in range(blocks.size()):
		blocks[i].color = color if i < health else empty_color
