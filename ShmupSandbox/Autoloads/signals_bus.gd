extends Node

signal give_score_when_hit(score : int)
signal give_score_when_killed(score : int)
signal player_died()
signal spawn_sprite_in_position(pos : Vector2)
signal player_shooting(bullet_scene:PackedScene, locations:Array[Vector2])

func score_when_hit(score : int) -> void:
	give_score_when_hit.emit(score) 

func score_when_killed(score : int) -> void:
	give_score_when_killed.emit(score) 

func player_death_event() -> void:
	player_died.emit()

func player_spawn_ready(pos : Vector2) -> void:
	spawn_sprite_in_position.emit(pos)

func player_shooting_event(bullet_scene:PackedScene, locations:Array[Vector2]):
	player_shooting.emit(bullet_scene, locations)
