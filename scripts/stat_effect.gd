class_name StatEffect
extends CollectibleData

enum Target { PLAYER, WAVE }

@export var target: Target = Target.PLAYER
@export var property: StringName = &""
@export var amount: float = 0.0

func apply(player: Player, wave: Wave) -> void:
	var node := _get_target(player, wave)
	var current = node.get(property)
	if current == null:
		push_warning("Propriété introuvable : %s" % property)
		return
	node.set(property, current + amount)

func remove(player: Player, wave: Wave) -> void:
	var node := _get_target(player, wave)
	if node.get(property) != null:
		node.set(property, node.get(property) - amount)

func _get_target(player: Player, wave: Wave) -> Node:
	return player if target == Target.PLAYER else wave
