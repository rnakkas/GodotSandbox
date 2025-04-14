extends Node

signal give_score_when_hit(score : int)
signal give_score_when_killed(score : int)
signal player_died()
signal spawn_player(pos : Vector2, can_be_invincible : bool)
signal player_shooting(bullet_scene:PackedScene, locations:Array[Vector2])
signal player_lives_depleted()
signal continue_game_player_respawn()

func score_when_hit(score : int) -> void:
	give_score_when_hit.emit(score) 

func score_when_killed(score : int) -> void:
	give_score_when_killed.emit(score) 

func player_death_event() -> void:
	player_died.emit()

func player_spawn_event(pos : Vector2, can_be_invincible : bool) -> void:
	spawn_player.emit(pos, can_be_invincible)

func player_shooting_event(bullet_scene:PackedScene, locations:Array[Vector2]) -> void:
	player_shooting.emit(bullet_scene, locations)

func player_lives_depleted_event() -> void:
	player_lives_depleted.emit()

func continue_game_player_respawn_event() -> void:
	continue_game_player_respawn.emit()