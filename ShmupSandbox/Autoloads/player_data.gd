extends Node

const _player_max_lives : int = 1

var player_lives : int

var player_score: int

var player_hi_scores_list : Array[int]

## TODO: Getting new player scores and making sure only the top 10 highest scores are saved
## Try: 
##		Get the new score
##		Append to this array
##		Sort the array in descending order for scores
##		Slice to only take indices 0 to 10, i.e. top 10 scores
var player_hi_scores_dictionaries : Array[Dictionary] = [
	{"score" : 107400, "name" : "APE"},
	{"score" : 90250, "name" : "YAN"},
	{"score" : 96000, "name" : "HIT"},
	{"score" : 110230, "name" : "IAN"},
	{"score" : 96000, "name" : "FAN"},
	{"score" : 84000, "name" : "GIT"},
	{"score" : 54100, "name" : "GAT"},
	{"score" : 91000, "name" : "APE"},
	{"score" : 72010, "name" : "BAD"},
	{"score" : 67200, "name" : "BAT"}
]

var enemies_killed: int


func reset_all_player_data_on_start() -> void:
	## Reset all the of player data for new game
	player_score = 0
	enemies_killed = 0
	player_lives = _player_max_lives
	
func set_player_lives_to_max() -> void:
	player_lives = _player_max_lives
