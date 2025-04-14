extends Node

const _player_max_lives : int = 0

var player_lives : int

var player_score: int

var player_hi_scores_list : Array[int]

var enemies_killed: int

func _ready() -> void:
	player_hi_scores_list.resize(10) ## TODO: To use for hi-score list, Array of size 10 for storing top 10 high scores
	print("high scores list: ", player_hi_scores_list)

func reset_all_player_data() -> void:
	## Reset all the of player data for new game
	player_score = 0
	enemies_killed = 0
	player_lives = _player_max_lives
	
func set_player_lives_to_max() -> void:
	player_lives = _player_max_lives