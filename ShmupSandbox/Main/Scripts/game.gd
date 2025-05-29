class_name Game extends Node2D

## Spawners
@onready var player_spawner_node : PlayerSpawner = $player_spawner 

## Containers
@onready var player_projectiles_container : Node2D = $PlayerProjectilesContainer
@onready var enemies_container : Node2D = $EnemiesContainer
@onready var pickups_container : Node2D = $PickupsContainer

## Shot limits
@export var shot_limit : int = 45
var active_shots : int


################################################
# NOTE: Ready
################################################
func _ready() -> void:
	SignalsBus.player_shooting.connect(self._on_player_shooting)
	player_spawner_node.spawn_player_sprite("spawn") ## play spawn animation for player


################################################
# NOTE: Player shooting
################################################
func _on_player_shooting(bullets_list : Array[PlayerBullet]) -> void:
	for bullet : PlayerBullet in bullets_list:
		# Track the active shots and use this to enforce shot limit
		active_shots += 1
		bullet.tree_exited.connect(self._on_bullet_freed)
		
		player_projectiles_container.add_child(bullet)
		
		# If shot limit reached, send signal to prevent player from shooting
		if active_shots >= shot_limit:
			SignalsBus.shot_limit_reached_event()
			break

## When bullet is freed, reduce active shot count to allow player to shoot again
func _on_bullet_freed() -> void:
	active_shots -= 1
	if active_shots <= shot_limit*0.2:
		SignalsBus.shot_limit_refreshed_event()


################################################
# NOTE: Spawning enemies
################################################
func _on_enemy_spawner_add_enemy_to_game(enemy: Area2D) -> void:
	enemies_container.add_child(enemy)


################################################
# NOTE: Spawning player's spawn sprite
################################################
func _on_player_spawner_add_player_spawn_sprite_to_game(spawn_sprite: AnimatedSprite2D) -> void:
	add_child(spawn_sprite)


################################################
# NOTE:Spawning player
################################################
func _on_player_spawner_add_player_to_game(player: PlayerCat) -> void:
	add_child(player)


################################################
# NOTE:Spawning pickups
################################################
func _on_pickups_spawner_add_pickup_to_game(pickup:Node2D) -> void:
	pickups_container.add_child(pickup)
