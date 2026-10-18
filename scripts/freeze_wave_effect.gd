class_name FreezeWaveEffect
extends CollectibleData

func apply(_player: Player, wave: Wave) -> void:
	wave.scroll_frozen += 1

func remove(_player: Player, wave: Wave) -> void:
	wave.scroll_frozen -= 1
