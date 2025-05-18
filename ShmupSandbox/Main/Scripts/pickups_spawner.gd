class_name PickupsSpanwer extends Node2D

@export var powerup_packed_scene : PackedScene = preload("res://ShmupSandbox/Pickups/Scenes/pickup_powerup.tscn")

signal add_pickup_to_game(pickup : Node2D)

func _ready() -> void:
	SignalsBus.spawn_powerup.connect(_on_spawn_powerup_event)


func _on_spawn_powerup_event(sp : Vector2) -> void:
	_instantiate_powerup(sp)

func _instantiate_powerup(sp : Vector2) -> void:
	var powerup : PickupPowerup = powerup_packed_scene.instantiate()
	powerup.global_position = Vector2(sp)
	add_pickup_to_game.emit(powerup)

