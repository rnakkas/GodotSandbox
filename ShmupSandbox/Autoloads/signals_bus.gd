extends Node

signal score_increased(score : int)
signal player_died()
signal spawn_player(pos : Vector2, can_be_invincible : bool)
signal player_shooting(bullets_list : Array[Area2D])
signal player_lives_updated()
signal continue_game_player_respawn()
signal player_score_updated()
signal game_loaded()
signal player_hi_score_name_entered(player_name : String)
signal player_pressed_pause_game()
signal player_credits_updated()
signal spawn_powerup(sp : Vector2)
signal powerup_collected(powerup : int)


func score_increased_event(score : int) -> void:
	score_increased.emit(score)

func player_death_event() -> void:
	player_died.emit()

func player_spawn_event(pos : Vector2, can_be_invincible : bool) -> void:
	spawn_player.emit(pos, can_be_invincible)

func player_shooting_event(bullets_list : Array[Area2D]) -> void:
	player_shooting.emit(bullets_list)

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

func player_pressed_pause_game_event() -> void:
	player_pressed_pause_game.emit()

func player_credits_updated_event() -> void:
	player_credits_updated.emit()

func spawn_powerup_event(sp : Vector2) -> void:
	spawn_powerup.emit(sp)

func powerup_collected_event(powerup : int) -> void:
	print("emit global signal, powrup collected: ", powerup)
	powerup_collected.emit(powerup)