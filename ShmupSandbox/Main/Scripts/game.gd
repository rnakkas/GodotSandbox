class_name game extends Node2D

## Spawners
@onready var player_spawner_node : player_spawner = $player_spawner 

## Containers
@onready var player_projectiles_container : Node2D = $PlayerProjectilesContainer
@onready var enemies_container : Node2D = $EnemiesContainer

func _ready() -> void:
	SignalsBus.player_shooting.connect(_on_player_shooting)
	player_spawner_node.spawn_player_sprite()

func _process(_delta: float) -> void:
	pass

## Player shooting
func _on_player_shooting(bullet_scene: PackedScene, locations: Array[Vector2]) -> void:
	for i:int in range(locations.size()):
		var bullet : player_bullet = bullet_scene.instantiate()
		bullet.position = locations[i]
		player_projectiles_container.add_child(bullet)


## Spawning enemies
func _on_enemy_spawner_add_enemy_to_game(enemy: Area2D) -> void:
	enemies_container.add_child(enemy)

## Spawning player's spawn sprite
func _on_player_spawner_add_player_spawn_sprite_to_game(spawn_sprite: AnimatedSprite2D) -> void:
	add_child(spawn_sprite)

## Spawning player
func _on_player_spawner_add_player_to_game(player: player_cat) -> void:
	add_child(player)
