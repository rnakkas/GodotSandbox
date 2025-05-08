extends Node

#### #### #### #### #### #### #### ####

## TODO: These will be changed via the options menus
## Game settings
var _player_max_lives : int = 3
var _player_max_credits : int = 3
var life_extend_score_1 : int = 100000
var life_extend_score_2 : int = 250000
const score_penallty_multiplier : float = 0.9

var game_settings_dictionary : Dictionary = {
	"player_max_lives" : _player_max_lives,
	"player_max_credits" : _player_max_credits,
	"life_extend_score_1" : life_extend_score_1,
	"life_extend_score_2" : life_extend_score_2
}

## Display settings
var window_mode : int = 3 # Fullscreen
var crt_filter : bool = false

var display_settings_dictionary : Dictionary = {
	"window_mode" : window_mode,
	"crt_filter" : crt_filter
}

## Audio settings
var master_volume : int = 100
var sound_volume : int = 75
var music_volume : int = 75

var audio_settings_dictionary : Dictionary = {
	"master_volume" : master_volume,
	"sound_volume" : sound_volume,
	"music_volume" : music_volume
}

#### #### #### #### #### #### #### ####

var life_extend_1_reached : bool
var life_extend_2_reached : bool

var player_lives : int
var player_credits : int

var player_score: int

var enemies_killed: int

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

## Connect to global signals
func _connect_to_signals() -> void:
	SignalsBus.score_increased.connect(_on_update_current_score)
	SignalsBus.continue_game_player_respawn.connect(_on_continue_refresh_player_data)
	SignalsBus.player_died.connect(_on_player_death)
	SignalsBus.game_loaded.connect(_on_game_loaded)
	SignalsBus.player_hi_score_name_entered.connect(_on_player_hi_score_name_entered)


## Sorting the high scores from highest to lowest
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


## Reset all the of player data for new game
func reset_all_player_data_on_start() -> void:
	player_score = 0
	enemies_killed = 0
	player_lives = _player_max_lives - 1
	player_credits = _player_max_credits - 1
	life_extend_1_reached = false
	life_extend_2_reached = false

	SignalsBus.player_score_updated_event()
	SignalsBus.player_lives_updated_event()
	SignalsBus.player_credits_updated_event()


## Get the high scores list from save game data
func _update_high_scores_from_save_data() -> void:
	player_hi_scores_dictionaries.clear()
	for entry in SaveManager.loaded_data["player_high_scores"]:
		if entry.has("score") && typeof(entry["score"] == TYPE_FLOAT): # Clean up scores from float to int
			entry["score"] = int(entry["score"])
		
		if typeof(entry) == TYPE_DICTIONARY: # Append the cleaned up scores to high score list
			player_hi_scores_dictionaries.append(entry)
		else:
			push_error("invalid score entry detected")


## Save the player's high scores to save file
func _save_player_hi_scores() -> void:
	SaveManager.contents_to_save["player_high_scores"] = player_hi_scores_dictionaries # Update with latest score data
	SaveManager.save_game()


####

## Signals connections

func _on_update_current_score(score : int) -> void:
	player_score += score
	_handle_life_extension()

	SignalsBus.player_score_updated_event()

## Helper func to extend life on reaching extend scores
func _handle_life_extension() -> void:
	if player_score >= life_extend_score_1 && !life_extend_1_reached:
		life_extend_1_reached = true
		player_lives += 1
		
	if player_score >= life_extend_score_2 && !life_extend_2_reached:
		life_extend_2_reached = true
		player_lives += 1

	SignalsBus.player_lives_updated_event()


func _on_continue_refresh_player_data() -> void:
	player_score = int(round(player_score * score_penallty_multiplier))
	player_lives = _player_max_lives
	player_credits -= 1

	SignalsBus.player_score_updated_event()
	SignalsBus.player_lives_updated_event()
	SignalsBus.player_credits_updated_event()


func _on_player_death() -> void:
	# Extend life before decreasing life on death if the score is higher than extension threshold
	_handle_life_extension() 
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
