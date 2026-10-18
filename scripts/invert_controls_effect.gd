class_name InvertControlsEffect
extends CollectibleData

func apply(player: Player, _wave: Wave) -> void:
	player.inverted_controls += 1

func remove(player: Player, _wave: Wave) -> void:
	player.inverted_controls -= 1
