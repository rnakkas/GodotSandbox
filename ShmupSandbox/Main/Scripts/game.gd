class_name Game extends Node2D

## Spawners
@onready var player_spawner_node : PlayerSpawner = $player_spawner 

## Containers
@onready var player_projectiles_container : Node2D = $PlayerProjectilesContainer
@onready var player_bombs_container : Node2D = $PlayerBombsContainer
@onready var enemies_container : Node2D = $EnemiesContainer
@onready var powerups_container : Node2D = $PowerupsContainer
@onready var score_items_container : Node2D = $ScoreItemsContainer
@onready var score_fragments_container : Node2D = $ScoreFragmentsContainer


## Shot limits
var shot_limit : int = 100
var active_shots : int


################################################
# NOTE: Ready
################################################
func _ready() -> void:
	_connect_to_signals()
	player_spawner_node.spawn_player_sprite("spawn") ## play spawn animation for player

func _connect_to_signals() -> void:
	SignalsBus.shot_limit_updated_event.connect(self._on_shot_limit_updated)
	SignalsBus.player_shooting_event.connect(self._on_player_shooting)
	SignalsBus.player_bombing_event.connect(self._on_player_bombing)


func _on_shot_limit_updated(limit : int) -> void:
	shot_limit = limit



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
			SignalsBus.shot_limit_reached_event.emit()
			break

## When bullet is freed, reduce active shot count to allow player to shoot again
func _on_bullet_freed() -> void:
	active_shots -= 1
	if active_shots <= shot_limit*0.2:
		SignalsBus.shot_limit_refreshed_event.emit()



################################################
# NOTE: Player Bombing
################################################
func _on_player_bombing(bomb : Area2D) -> void:
	player_bombs_container.add_child(bomb)



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
# NOTE:Spawning powerups
################################################
func _on_pickups_spawner_add_powerup_to_game(powerup:PickupPowerup) -> void:
	powerups_container.add_child(powerup)


################################################
# NOTE:Spawning score items
################################################
func _on_pickups_spawner_add_score_item_to_game(score_item:PickupScore) -> void:
	score_items_container.add_child(score_item)


################################################
# NOTE:Spawning score fragments
################################################
func _on_pickups_spawner_add_score_fragment_to_game(score_fragment:ScoreFragment) -> void:
	score_fragments_container.add_child(score_fragment)
