extends Node

var player_lives : int = 3

var player_score: int = 0

var player_hi_scores_list : Array[int]

var enemies_killed: int = 0

func _ready() -> void:
	player_hi_scores_list.resize(10) ## Array of size 10 for storing top 10 high scores
	print("high scores list: ", player_hi_scores_list)
