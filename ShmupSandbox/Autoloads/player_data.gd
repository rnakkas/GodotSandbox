extends Node

var player_lives : int

var player_score: int

var player_hi_scores_list : Array[int]

var enemies_killed: int

func _ready() -> void:
	player_hi_scores_list.resize(10) ## Array of size 10 for storing top 10 high scores
	print("high scores list: ", player_hi_scores_list)
