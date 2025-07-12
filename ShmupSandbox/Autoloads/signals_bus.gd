extends Node

@warning_ignore("unused_signal")
signal score_increased_event(score: int)

@warning_ignore("unused_signal")
signal player_death_event()

@warning_ignore("unused_signal")
signal player_spawn_event(pos: Vector2, can_be_invincible: bool)

@warning_ignore("unused_signal")
signal player_shooting_event(bullets_list: Array[PlayerBullet])

@warning_ignore("unused_signal")
signal player_bombing_event(bomb: Area2D)

@warning_ignore("unused_signal")
signal player_lives_updated_event()

@warning_ignore("unused_signal")
signal player_bombs_updated_event()

@warning_ignore("unused_signal")
signal continue_game_player_respawn_event()

@warning_ignore("unused_signal")
signal player_score_updated_event()

@warning_ignore("unused_signal")
signal game_loaded_event()

@warning_ignore("unused_signal")
signal player_hi_score_name_entered_event(player_name: String)

@warning_ignore("unused_signal")
signal player_pressed_pause_game_event()

@warning_ignore("unused_signal")
signal player_credits_updated_event()

@warning_ignore("unused_signal")
signal spawn_powerup_event(sp: Vector2)

@warning_ignore("unused_signal")
signal spawn_score_item_event(sp: Vector2)

@warning_ignore("unused_signal")
signal spawn_score_fragment_event(sp: Vector2)

@warning_ignore("unused_signal")
signal powerup_collected_event(powerup: int, score: int)

@warning_ignore("unused_signal")
signal powerup_max_level_event(powerup: int)

@warning_ignore("unused_signal")
signal shot_limit_reached_event()

@warning_ignore("unused_signal")
signal shot_limit_refreshed_event()

@warning_ignore("unused_signal")
signal shot_limit_updated_event(shot_limit: int)


################################################
#NOTE:Spawning enemies
################################################
@warning_ignore("unused_signal")
signal spawn_enemy_doomboard_event(sp: Vector2)

@warning_ignore("unused_signal")
signal spawn_enemy_boomer_event(sp: Vector2)

@warning_ignore("unused_signal")
signal spawn_enemy_screamer_1_event(sp: Vector2)

@warning_ignore("unused_signal")
signal spawn_enemy_screamer_2_event(path: Path2D)

@warning_ignore("unused_signal")
signal spawn_enemy_screamer_3_event(sp: Vector2)

@warning_ignore("unused_signal")
signal spawn_enemy_soul_carrier_event(sp: Vector2)

@warning_ignore("unused_signal")
signal spawn_enemy_rumbler_event(sp: Vector2)

@warning_ignore("unused_signal")
signal spawn_enemy_vile_v_event(sp: Vector2)

@warning_ignore("unused_signal")
signal spawn_enemy_axecutioner_event(sp: Vector2)

@warning_ignore("unused_signal")
signal spawn_enemy_bass_behemoth_event(sp: Vector2)

@warning_ignore("unused_signal")
signal spawn_enemy_rimshot_event(sp: Vector2)

################################################
#NOTE:Enemy stuff
################################################
@warning_ignore("unused_signal")
signal enemy_shooting_event(bullets_list: Array[Area2D])