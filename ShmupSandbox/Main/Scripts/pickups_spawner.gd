class_name PickupsSpanwer extends Node2D

@onready var test_spawn_timer : Timer = $SpawnTimer_FOR_TESTING_ONLY

@export var powerup_packed_scene : PackedScene = preload("res://ShmupSandbox/Pickups/Scenes/pickup_powerup.tscn")

var sp_x : float

var viewport_size : Vector2 

signal add_pickup_to_game(pickup : Node2D)

func _ready() -> void:
	viewport_size = get_viewport_rect().size
	sp_x = viewport_size.x + 20.0


func _on_spawn_timer_for_testing_only_timeout() -> void:
	_spawn_powerup()

func _spawn_powerup() -> void:
	var powerup : PickupPowerup = powerup_packed_scene.instantiate()
	var sp_y = randf_range(0, viewport_size.y)
	powerup.global_position = Vector2(sp_x, sp_y)
	
	add_pickup_to_game.emit(powerup)

