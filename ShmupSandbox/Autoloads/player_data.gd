extends Node

const _player_max_lives : int = 0
const _player_max_credits : int = 1

var player_lives : int
var player_credits : int

var player_score: int

var enemies_killed: int

const score_penallty_multiplier : float = 0.9

## The default high score list when there is no save data
var player_hi_scores_dictionaries : Array[Dictionary] = [
	{"score" : 200, "name" : "APE"},
	{"score" : 300, "name" : "YAN"},
	{"score" : 420, "name" : "HIT"},
	{"score" : 500, "name" : "IAN"},
	{"score" : 600, "name" : "FAN"},
	{"score" : 700, "name" : "GIT"},
	{"score" : 800, "name" : "GAT"},
	{"score" : 900, "name" : "APE"},
	{"score" : 1111, "name" : "BAD"},
	{"score" : 1100, "name" : "BAT"}
]


func _ready() -> void:
	sort_high_scores()
	_connect_to_signals()


## Helper funcs

func _connect_to_signals() -> void:
	SignalsBus.score_increased.connect(_on_update_current_score)
	SignalsBus.continue_game_player_respawn.connect(_on_continue_refresh_player_data)
	SignalsBus.player_died.connect(_on_player_death)
	SignalsBus.game_loaded.connect(_on_game_loaded)
	SignalsBus.player_hi_score_name_entered.connect(_on_player_hi_score_name_entered)


func sort_high_scores() -> void:
	## Sort the high scores dictionaries by score
	player_hi_scores_dictionaries.sort_custom(func(a, b):
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
	player_credits = _player_max_credits

	SignalsBus.player_score_updated_event()
	SignalsBus.player_lives_updated_event()
	SignalsBus.player_credits_updated_event()
	

# func set_player_lives_to_max() -> void:
# 	player_lives = _player_max_lives


func _update_high_scores_from_save_data() -> void:
	player_hi_scores_dictionaries.clear()
	for entry in SaveManager.loaded_data["player_high_scores"]:
		if entry.has("score") && typeof(entry["score"] == TYPE_FLOAT): # Clean up scores from float to int
			entry["score"] = int(entry["score"])
		
		if typeof(entry) == TYPE_DICTIONARY: # Append the cleaned up scores to high score list
			player_hi_scores_dictionaries.append(entry)
		else:
			push_error("invalid score entry detected")


func _save_player_hi_scores() -> void:
	SaveManager.contents_to_save["player_high_scores"] = player_hi_scores_dictionaries # Update with latest score data
	SaveManager.save_game()


####

## Signals connections

func _on_update_current_score(score : int) -> void:
	player_score += score
	SignalsBus.player_score_updated_event()


func _on_continue_refresh_player_data() -> void:
	player_score = int(round(player_score * score_penallty_multiplier))
	player_lives = _player_max_lives
	player_credits -= 1
	print(player_credits)

	SignalsBus.player_score_updated_event()
	SignalsBus.player_lives_updated_event()
	SignalsBus.player_credits_updated_event()


func _on_player_death() -> void:
	player_lives -= 1
	SignalsBus.player_lives_updated_event()


func _on_game_loaded() -> void:
	_update_high_scores_from_save_data()


func _on_player_hi_score_name_entered(player_name : String) -> void:
	player_hi_scores_dictionaries.append(
		{"score" : player_score, "name" : player_name}
	)
	sort_high_scores()
	_save_player_hi_scores()
