class_name Game extends Node2D

## Spawners
@onready var player_spawner_node : PlayerSpawner = $player_spawner 

## Containers
@onready var player_projectiles_container : Node2D = $PlayerProjectilesContainer
@onready var enemies_container : Node2D = $EnemiesContainer
@onready var pickups_container : Node2D = $PickupsContainer

func _ready() -> void:
	SignalsBus.player_shooting.connect(_on_player_shooting)
	player_spawner_node.spawn_player_sprite("spawn") ## play spawn animation for player

func _process(_delta: float) -> void:
	pass

## Player shooting
func _on_player_shooting(bullets_list : Array[PlayerBullet]) -> void:
	for bullet : PlayerBullet in bullets_list:
		player_projectiles_container.add_child(bullet)


## Spawning enemies
func _on_enemy_spawner_add_enemy_to_game(enemy: Area2D) -> void:
	enemies_container.add_child(enemy)

## Spawning player's spawn sprite
func _on_player_spawner_add_player_spawn_sprite_to_game(spawn_sprite: AnimatedSprite2D) -> void:
	add_child(spawn_sprite)

## Spawning player
func _on_player_spawner_add_player_to_game(player: PlayerCat) -> void:
	add_child(player)

## Spawning pickups
func _on_pickups_spawner_add_pickup_to_game(pickup:Node2D) -> void:
	pickups_container.add_child(pickup)
