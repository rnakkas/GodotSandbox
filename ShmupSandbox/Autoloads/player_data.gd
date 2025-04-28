extends Node

const _player_max_lives : int = 1

var player_lives : int

var player_score: int

var enemies_killed: int

const continue_score_deduction : float = 0.9

## TODO: Getting new player scores and making sure only the top 10 highest scores are saved
## Try: 
##		Get the new score
##		Append to this array
##		Sort the array in descending order for scores
##		Slice to only take indices 0 to 10, i.e. top 10 scores
var player_hi_scores_dictionaries : Array[Dictionary] = [
	{"score" : 200, "name" : "APE"},
	{"score" : 300, "name" : "YAN"},
	{"score" : 400, "name" : "HIT"},
	{"score" : 500, "name" : "IAN"},
	{"score" : 600, "name" : "FAN"},
	{"score" : 700, "name" : "GIT"},
	{"score" : 800, "name" : "GAT"},
	{"score" : 900, "name" : "APE"},
	{"score" : 1000, "name" : "BAD"},
	{"score" : 1100, "name" : "BAT"}
]


func _ready() -> void:
	sort_high_scores()
	_connect_to_signals()
	player_hi_scores_dictionaries.sort()


## Helper funcs

func _connect_to_signals() -> void:
	SignalsBus.score_increased.connect(_on_update_current_score)
	SignalsBus.continue_game_player_respawn.connect(_on_continue_score_deduced)
	SignalsBus.player_died.connect(_on_player_death)


func sort_high_scores() -> void:
	## Sort the high scores dictionaries by score
	PlayerData.player_hi_scores_dictionaries.sort_custom(func(a, b):
		# First, compare by score in descending order
		if a["score"] != b["score"]:
			return a["score"] > b["score"]

		# If scores are the same, compare by name alphabetically (ascending)
		return a["name"] < b["name"]
	)

	player_hi_scores_dictionaries = player_hi_scores_dictionaries.slice(0,10) # Only keep the top 10 scores


func reset_all_player_data_on_start() -> void:
	## Reset all the of player data for new game
	player_score = 0
	enemies_killed = 0
	player_lives = _player_max_lives
	

func set_player_lives_to_max() -> void:
	player_lives = _player_max_lives


####

## Signals connections

func _on_update_current_score(score : int) -> void:
	player_score += score
	SignalsBus.player_score_updated_event()


func _on_continue_score_deduced() -> void:
	player_score = int(round(player_score * continue_score_deduction))
	SignalsBus.player_score_updated_event()


func _on_player_death() -> void:
	player_lives -= 1
	SignalsBus.player_lives_updated_event()



