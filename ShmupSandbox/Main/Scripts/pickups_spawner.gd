class_name PickupsSpanwer extends Node2D

@export var powerup_packed_scene : PackedScene = preload("res://ShmupSandbox/Pickups/Scenes/pickup_powerup.tscn")
@export var sccore_item_packed_scene : PackedScene = preload("res://ShmupSandbox/Pickups/Scenes/pickup_score.tscn")

signal add_pickup_to_game(pickup : Node2D)

func _ready() -> void:
	SignalsBus.spawn_powerup_event.connect(self._on_spawn_powerup_event)
	SignalsBus.spawn_score_item_event.connect(self._on_spawn_score_item_event)


func _on_spawn_powerup_event(sp : Vector2) -> void:
	_instantiate_powerup(sp)

func _instantiate_powerup(sp : Vector2) -> void:
	var powerup : PickupPowerup = powerup_packed_scene.instantiate()
	powerup.global_position = sp
	add_pickup_to_game.emit(powerup)


func _on_spawn_score_item_event(sp: Vector2) -> void:
	_instantiate_score_item(sp)

func _instantiate_score_item(sp : Vector2) -> void:
	var score_item : PickupScore = sccore_item_packed_scene.instantiate()
	score_item.global_position = sp
	add_pickup_to_game.emit(score_item)