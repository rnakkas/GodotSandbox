extends Node

################################################
#NOTE: Constant game settings, will not be changed
################################################
const life_extend_score_1 : int = 100000
const life_extend_score_2 : int = 250000
const score_penallty_multiplier : float = 0.9


################################################
#NOTE: Default game settings
################################################
var _player_max_lives : int = 3
var _player_max_credits : int = 3

var game_settings_dictionary : Dictionary = {
	"player_max_lives" : _player_max_lives,
	"player_max_credits" : _player_max_credits
}


################################################
#NOTE: Default display settings
################################################
var window_mode : int = DisplayServer.WINDOW_MODE_FULLSCREEN
var crt_filter : bool = false

var display_settings_dictionary : Dictionary = {
	"window_mode" : window_mode,
	"crt_filter" : crt_filter
}


################################################
#NOTE: Default audio settings
################################################
const volume_max : int = 100
const volume_min : int = 0
var master_volume : int = 100
var sound_volume : int = 75
var music_volume : int = 75

var audio_settings_dictionary : Dictionary = {
	"master_volume" : master_volume,
	"sound_volume" : sound_volume,
	"music_volume" : music_volume
}


################################################
#NOTE: Game states, variable and data
################################################
var life_extend_1_reached : bool
var life_extend_2_reached : bool

var player_lives : int
var player_credits : int

var player_score: int

var enemies_killed: int

var is_game_running: bool


################################################
#NOTE: Default list of player high scores
################################################
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


################################################
#NOTE: Ready
################################################
func _ready() -> void:
	sort_high_scores()
	_connect_to_signals()

## Connect to global signals
func _connect_to_signals() -> void:
	SignalsBus.score_increased.connect(_on_update_current_score)
	SignalsBus.continue_game_player_respawn.connect(_on_continue_refresh_player_data)
	SignalsBus.player_died.connect(_on_player_death)
	SignalsBus.game_loaded.connect(_on_game_loaded)
	SignalsBus.player_hi_score_name_entered.connect(_on_player_hi_score_name_entered)


################################################
#NOTE: Helper func to sort player high scores from highest to lowest
################################################
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



################################################
#NOTE: Save high scores to save file
################################################
## Save high scores
func _save_high_scores() -> void:
	SaveManager.contents_to_save["player_high_scores"] = player_hi_scores_dictionaries # Update with latest score data
	SaveManager.save_game()



################################################
#NOTE: Reset all the of player data for new game, called by Main.gd
################################################
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



################################################
#NOTE: Signal connection: current score updated
################################################
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


################################################
#NOTE: Signal connection: Continue game refresh player data
################################################
func _on_continue_refresh_player_data() -> void:
	player_score = int(round(player_score * score_penallty_multiplier))
	player_lives = _player_max_lives
	player_credits -= 1

	SignalsBus.player_score_updated_event()
	SignalsBus.player_lives_updated_event()
	SignalsBus.player_credits_updated_event()


################################################
#NOTE: Signal connection: player death event
################################################
func _on_player_death() -> void:
	# Extend life before decreasing life on death if the score is higher than extension threshold
	_handle_life_extension() 
	player_lives -= 1
	SignalsBus.player_lives_updated_event()


################################################
#NOTE: Signal connection: player entered name for high score
################################################
func _on_player_hi_score_name_entered(player_name : String) -> void:
	player_hi_scores_dictionaries.append(
		{"score" : player_score, "name" : player_name}
	)
	sort_high_scores()
	_save_high_scores()



################################################
#NOTE: Signal connection: Load game and set data from the loaded data
################################################
func _on_game_loaded() -> void:
	_update_high_scores_from_save_data()
	_update_game_settings_from_save_data()
	_update_display_settings_from_save_data()
	_update_audio_settings_from_save_data()


## Update the high scores list from save game data
func _update_high_scores_from_save_data() -> void:
	# If save file doesn't have any high score data, return gracefully and use default scores
	if !SaveManager.loaded_data.has("player_high_scores"):
		push_warning("No high scores found in save file, using default high score list")
		return

	player_hi_scores_dictionaries.clear()
	for entry in SaveManager.loaded_data["player_high_scores"]:
		if entry.has("score") && typeof(entry["score"]) == TYPE_FLOAT: # Clean up scores from float to int
			entry["score"] = int(entry["score"])
		
		if typeof(entry) == TYPE_DICTIONARY: # Append the cleaned up scores to high score list
			player_hi_scores_dictionaries.append(entry)
		else:
			push_error("invalid score entry detected")
	
	# Update save contents with the latest data after load
	SaveManager.contents_to_save["player_high_scores"] = player_hi_scores_dictionaries


## Update the game settings from save game data
func _update_game_settings_from_save_data() -> void:
	# If save file doesn't have settings, retunr gracefully and use default settings
	if !SaveManager.loaded_data.has("settings") || !SaveManager.loaded_data["settings"].has("game_settings"):
		push_warning("No settings or game settings found in save file, using default game settings")
		return

	game_settings_dictionary.clear()
	for entry in SaveManager.loaded_data["settings"]["game_settings"]:
		var entry_value = SaveManager.loaded_data["settings"]["game_settings"][entry]
		if typeof(entry_value) == TYPE_FLOAT:
			entry_value = int(entry_value)
			if entry == "player_max_lives":
				_player_max_lives = entry_value
			if entry == "player_max_credits":
				_player_max_credits = entry_value
	
	# Update save contents with the latest data after load
	SaveManager.contents_to_save["settings"]["game_settings"] = SaveManager.loaded_data["settings"]["game_settings"]


## Update the display settings from save game data
func _update_display_settings_from_save_data() -> void:
	if !SaveManager.loaded_data.has("settings") || !SaveManager.loaded_data["settings"].has("display_settings"):
		push_warning("No settings or display settings found in save file, using default display settings")
		return
	
	display_settings_dictionary.clear()
	for entry in SaveManager.loaded_data["settings"]["display_settings"]:
		var entry_value = SaveManager.loaded_data["settings"]["display_settings"][entry]
		if entry == "window_mode":
			if typeof(entry_value) == TYPE_FLOAT:
				entry_value = int(entry_value)
			DisplayServer.window_set_mode(entry_value)
			if (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED):
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false) # Allows title bar and border for resize
			window_mode = DisplayServer.window_get_mode()
		if entry == "crt_filter":
			if typeof(entry_value) == TYPE_BOOL:
				crt_filter = entry_value
	
	# Update save contents with the latest data after load
	SaveManager.contents_to_save["settings"]["display_settings"] = SaveManager.loaded_data["settings"]["display_settings"]


## Update the audio settings from the save game data
func _update_audio_settings_from_save_data() -> void:
	if !SaveManager.loaded_data.has("settings") || !SaveManager.loaded_data["settings"].has("audio_settings"):
		push_warning("No settings or audio settings found in save file, using default audio settings")
		return
	
	audio_settings_dictionary.clear()
	for entry in SaveManager.loaded_data["settings"]["audio_settings"]:
		var entry_value = SaveManager.loaded_data["settings"]["audio_settings"][entry]
		if typeof(entry_value) == TYPE_FLOAT:
			entry_value = int(entry_value)
			if entry == "master_volume":
				master_volume = entry_value
			if entry == "sound_volume":
				sound_volume = entry_value
			if entry == "music_volume":
				music_volume = entry_value
	
	# Update save contents with the latest data after load
	SaveManager.contents_to_save["settings"]["audio_settings"] = SaveManager.loaded_data["settings"]["audio_settings"]