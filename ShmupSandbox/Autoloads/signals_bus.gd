extends Node

signal give_score_when_hit(score : int)
signal give_score_when_killed(score : int)

func score_when_hit(score : int) -> void:
	give_score_when_hit.emit(score) 

func score_when_killed(score : int) -> void:
	give_score_when_killed.emit(score) 
