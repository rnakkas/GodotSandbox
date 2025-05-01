extends Node

signal score_increased(score : int)
signal player_died()
signal spawn_player(pos : Vector2, can_be_invincible : bool)
signal player_shooting(bullet_scene:PackedScene, locations:Array[Vector2])
signal player_lives_updated()
signal continue_game_player_respawn()
signal player_score_updated()
signal game_loaded()
signal player_hi_score_name_entered(player_name : String)


func score_increased_event(score : int) -> void:
	score_increased.emit(score)

func player_death_event() -> void:
	player_died.emit()

func player_spawn_event(pos : Vector2, can_be_invincible : bool) -> void:
	spawn_player.emit(pos, can_be_invincible)

func player_shooting_event(bullet_scene:PackedScene, locations:Array[Vector2]) -> void:
	player_shooting.emit(bullet_scene, locations)

func player_lives_updated_event() -> void:
	player_lives_updated.emit()

func continue_game_player_respawn_event() -> void:
	continue_game_player_respawn.emit()

func player_score_updated_event() -> void:
	player_score_updated.emit()

func game_loaded_event() -> void:
	game_loaded.emit()

func player_hi_score_name_entered_event(player_name : String) -> void:
	player_hi_score_name_entered.emit(player_name)