extends Node2D

@export var player: Player
@export var wave: Wave

@export var collectible_scene: PackedScene
@export var collectibles: Array[CollectibleData] = []

@export_group("Difficulté")
@export var ramp_duration: float = 180.0        # secondes pour atteindre la difficulté max
@export var spawn_interval_start: float = 2.0   # secondes entre deux apparitions au début
@export var spawn_interval_end: float = 0.5     # … et à la fin
@export var loot_speed_start: float = 120.0
@export var loot_speed_end: float = 300.0
@export var malus_weight_end: float = 1.8       # malus 1,8× plus fréquents à la fin
@export var scroll_bonus_end: float = 2.0       # vitesse de défilement ajoutée à la fin

@export_file("*.tscn") var menu_scene: String = "res://scenes/menu.tscn"

@onready var spawn: Node2D = %Spawn
@onready var spawn_follow: PathFollow2D = %PathFollow2D
@onready var spawn_timer: Timer = %SpawnTimer
@onready var health_bar: HealthBlocks = %HealthBar
@onready var crt: ColorRect = %CRT
@onready var game_over: CanvasLayer = %GameOver
@onready var score_over_label: Label = %ScoreOverLabel
@onready var restart_button: Button = %RestartButton
@onready var menu_button: Button = %MenuButton
@onready var score: Score = $Score
@onready var score_label: Label = %ScoreLabel
@onready var combo_label: Label = %ComboLabel
@onready var pause_menu: Control = %PauseMenu

var elapsed: float = 0.0
var difficulty: float = 0.0   # de 0 (début) à 1 (max)
var is_game_over: bool = false

func _ready() -> void:
	game_over.hide()
	spawn_timer.timeout.connect(spawn_object)
	player.health_changed.connect(_on_health_changed)
	_on_health_changed(player.health, player.max_health) 
	player.died.connect(_on_died) 
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	score.score_changed.connect(_on_score_changed)
	score.combo_changed.connect(_on_combo_changed)
	_on_score_changed(0)
	combo_label.hide()
	pause_menu.build_lexicon(collectibles)

func _process(delta: float) -> void:
	if is_game_over:
		return
	elapsed += delta
	difficulty = clampf(elapsed / ramp_duration, 0.0, 1.0)
	wave.difficulty_scroll = scroll_bonus_end * difficulty

func spawn_object() -> void:
	if collectibles.is_empty():
		return
		
	# Le prochain spawn arrivera plus vite
	spawn_timer.wait_time = lerpf(spawn_interval_start, spawn_interval_end, difficulty)

	spawn_follow.progress_ratio = randf()
	var spawn_pos: Vector2 = spawn_follow.global_position

	var from_right: bool = randf() < 0.5
	var spawn_direction := Vector2.RIGHT
	if from_right:
		spawn_pos.x = get_viewport_rect().size.x - spawn_pos.x
		spawn_direction = Vector2.LEFT

	var loot: Collectible = collectible_scene.instantiate()
	loot.data = pick_random_collectible()
	loot.position = to_local(spawn_pos)
	loot.direction = spawn_direction
	loot.collected.connect(_on_collected)
	loot.speed = lerpf(loot_speed_start, loot_speed_end, difficulty) * randf_range(0.8, 1.2)
	
	get_node("Spawn").add_child(loot)

func _weight(c: CollectibleData) -> float:
	if c.is_bonus:
		return c.spawn_weight
	return c.spawn_weight * lerpf(1.0, malus_weight_end, difficulty)

func pick_random_collectible() -> CollectibleData:
	var total := 0.0
	for c in collectibles:
		total += _weight(c)
	var roll := randf() * total
	for c in collectibles:
		roll -= _weight(c)
		if roll <= 0.0:
			return c
	return collectibles.back()

func _on_collected(data: CollectibleData, points: int) -> void:
	await get_tree().create_timer(data.duration, false).timeout
	score.register(data, points)
	data.apply(player, wave)

	if data.duration > 0.0:
		await get_tree().create_timer(data.duration).timeout
		if is_instance_valid(player) and is_instance_valid(wave):
			data.remove(player, wave)

func _on_score_changed(value: int) -> void:
	score_label.text = "%06d" % value 

func _on_combo_changed(combo: int, multiplier: int) -> void:
	combo_label.visible = combo >= 2
	combo_label.text = "COMBO x%d" % multiplier

	# Petit effet de « pop » à chaque nouveau combo
	if combo >= 2:
		combo_label.pivot_offset = combo_label.size / 2.0
		combo_label.scale = Vector2(1.4, 1.4)
		create_tween().tween_property(combo_label, "scale", Vector2.ONE, 0.15)

func _on_health_changed(health: int, max_health: int) -> void:
	health_bar.set_health(health, max_health)

func _on_died() -> void:
	pause_menu.can_pause = false
	is_game_over = true
	spawn.queue_free()
	player.queue_free()
	wave.modulate = Color.RED
	wave.flatten_game_over()
	crt.queue_free()
	var is_record: bool = GameState.submit_score(score.score)
	score_over_label.text = "SCORE %06d\nBEST  %06d" % [score.score, GameState.best_score]
	if is_record:
		score_over_label.text += "\nNEW RECORD!"
	game_over.visible = true

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	
func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(menu_scene)
