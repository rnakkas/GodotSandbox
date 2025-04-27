extends Node

const _player_max_lives : int = 1

var player_lives : int

var player_score: int

var player_hi_scores_list : Array[int]

var player_hi_scores_and_names_list : Array[Dictionary] = [
	{107400 : "APE"},
	{90250 : "YAN"},
	{96000 : "HIT"},
	{110230 : "IAN"},
	{96000 : "FAN"},
	{84000 : "GIT"},
	{54100 : "GAT"},
	{91000 : "APE"},
	{72010 : "BAD"},
	{67200 : "BAT"}
]

var enemies_killed: int

func _ready() -> void:
	
	## TODO:
	for i : int in range(player_hi_scores_and_names_list.size()):
		print("score and name: \n", player_hi_scores_and_names_list[i])
		print("score: ", player_hi_scores_and_names_list[i].keys()[0])
		
		player_hi_scores_list.append(player_hi_scores_and_names_list[i].keys()[0])
		player_hi_scores_list.sort()
		player_hi_scores_list.reverse()
		
		for score in player_hi_scores_and_names_list[i]:
			print("name: ", player_hi_scores_and_names_list[i][score], "\n")


	
	print("scores : " , player_hi_scores_list, "\n")

func reset_all_player_data_on_start() -> void:
	## Reset all the of player data for new game
	player_score = 0
	enemies_killed = 0
	player_lives = _player_max_lives
	
func set_player_lives_to_max() -> void:
	player_lives = _player_max_lives
