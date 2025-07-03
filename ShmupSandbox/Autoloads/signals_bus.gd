extends Node

signal score_increased_event(score : int)

signal player_death_event()

signal player_spawn_event(pos : Vector2, can_be_invincible : bool)

signal player_shooting_event(bullets_list : Array[PlayerBullet])

signal player_bombing_event(bomb : Area2D)

signal player_lives_updated_event()

signal player_bombs_updated_event()

signal continue_game_player_respawn_event()

signal player_score_updated_event()

signal game_loaded_event()

signal player_hi_score_name_entered_event(player_name : String)

signal player_pressed_pause_game_event()

signal player_credits_updated_event()

signal spawn_powerup_event(sp : Vector2)

signal spawn_score_item_event(sp : Vector2)

signal spawn_score_fragment_event(sp : Vector2)

signal powerup_collected_event(powerup : int, score : int)

signal powerup_max_level_event(powerup : int)

signal shot_limit_reached_event()

signal shot_limit_refreshed_event()

signal shot_limit_updated_event(shot_limit : int)



################################################
#NOTE:Spawning enemies
################################################

signal spawn_enemy_doomboard_event(sp : Vector2)

signal spawn_enemy_boomer_event(sp : Vector2)

signal spawn_enemy_screamer_1_event(sp : Vector2)

signal spawn_enemy_screamer_2_event(path : Path2D)

signal spawn_enemy_screamer_3_event(sp : Vector2)

signal spawn_enemy_soul_carrier_event(sp : Vector2)

signal spawn_enemy_rumbler_event(sp : Vector2)


################################################
#NOTE:Enemy stuff
################################################

signal enemy_shooting_event(bullets_list : Array[Area2D])