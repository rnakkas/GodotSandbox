class_name game extends Node2D

## Player
@onready var player : CharacterBody2D

## Containers
@onready var player_projectiles_container : Node2D = $PlayerProjectilesContainer
@onready var enemies_container : Node2D = $EnemiesContainer

func _ready() -> void:
	pass 

func _process(_delta: float) -> void:
	pass

## Player shooting
func _on_player_ship_shooting(bullet_scene: PackedScene, locations: Array[Vector2]) -> void:
	for i:int in range(locations.size()):
		var bullet := bullet_scene.instantiate()
		bullet.position = locations[i]
		player_projectiles_container.add_child(bullet)

## Spawning enemies
func _on_enemy_spawner_add_enemy_to_game(enemy: Area2D) -> void:
	enemies_container.add_child(enemy)
