class_name player_spawner extends Node2D

@export var player_sprite_scene : PackedScene = preload("res://ShmupSandbox/Player/Scenes/player_spawn_sprite.tscn")
@export var player_scene : PackedScene = preload("res://ShmupSandbox/Player/Scenes/player_cat.tscn")

@onready var spawn_point : Marker2D = $spawn_point

signal add_player_spawn_sprite_to_game(spawn_sprite : AnimatedSprite2D)
signal add_player_to_game(player : player_cat)

## Need these since the spawn sprite and the player character sprites are offset bit a bit
var x_offset : float = 12.0
var y_offset : float = 5.0

func _ready() -> void:
	_connect_to_signals()


func _connect_to_signals() -> void:
	SignalsBus.player_died.connect(_on_player_death)
	SignalsBus.spawn_sprite_in_position.connect(_on_player_spawn_ready)


####

## Connected signal methods
func _on_player_death() -> void:
	spawn_player_sprite()

func _on_player_spawn_ready(pos : Vector2) -> void:
	var player : player_cat = player_scene.instantiate()
	player.global_position = Vector2(pos.x + x_offset, pos.y + y_offset)
	add_player_to_game.emit(player)


####

## Helper funcs
func spawn_player_sprite() -> void:
	var spawn_sprite : AnimatedSprite2D = player_sprite_scene.instantiate()
	spawn_sprite.global_position = spawn_point.global_position
	add_player_spawn_sprite_to_game.emit(spawn_sprite)
