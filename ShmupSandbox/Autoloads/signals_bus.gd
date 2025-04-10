extends Node

signal give_score_when_hit(score : int)
signal give_score_when_killed(score : int)
signal player_died()

func score_when_hit(score : int) -> void:
	give_score_when_hit.emit(score) 

func score_when_killed(score : int) -> void:
	give_score_when_killed.emit(score) 

func player_death_event() -> void:
	player_died.emit()
