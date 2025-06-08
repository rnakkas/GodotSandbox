extends Node

# const save_location : String = "user://save_file.json"

const base_path : String = "user://"
const backup_file : String = "user://save.bak"  # Single backup file (save.bak)
const main_save_path : String = "user://save_file.json"  # Path to the main save file

var contents_to_save : Dictionary = {
	"test_message": "If you can read this, saving works :)",
	"player_high_scores" : GameManager.player_hi_scores_dictionaries,
	"settings" : {
		"game_settings" : GameManager.game_settings_dictionary,
		"display_settings" : GameManager.display_settings_dictionary,
		"audio_settings" : GameManager.audio_settings_dictionary
	}
}

var loaded_data : Dictionary = {}


func _ready() -> void:
	_load_game()


## Function to save the current game state
func save_game() -> void:
	# Make a backup of the current save file before overwriting it
	if FileAccess.file_exists(main_save_path):
		var dir : DirAccess = DirAccess.open(base_path)  # Open the user directory to perform file operations
		dir.copy(main_save_path, backup_file)  # Copy the current save file to the backup location

	# Now save the new game state
	var file : FileAccess = FileAccess.open(main_save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(contents_to_save, "\t"))  # Save data in JSON format
	file.close()


## Helper function to load and parse a JSON file
func _load_json_file(file_path : String) -> Variant:
	if !FileAccess.file_exists(file_path):
		push_warning("File does not exist: " + file_path)
		return null
	
	var file : FileAccess = FileAccess.open(file_path, FileAccess.READ)

	if !file:
		push_warning("Failed to read from file: " + file_path)
		return null
	
	var json_string : String = file.get_as_text()
	var parse_result : Variant = JSON.parse_string(json_string)
	
	if typeof(parse_result) == TYPE_DICTIONARY:
		return parse_result
	else:
		push_warning("Failed to parse JSON from file: " + file_path)
		return null


## Function to restore from backup and copy it to the main save location
func _restore_from_backup() -> void:
	# Load the backup file
	var load_data : Variant = _load_json_file(backup_file)
	if load_data != null:
		# If valid, copy the backup to the main save file location
		var dir : DirAccess = DirAccess.open("user://")  # Open the user directory to perform file operations
		dir.copy(backup_file, main_save_path)  # Copy the backup file to the main save location

		loaded_data = load_data  # Store the data
		SignalsBus.game_loaded_event.emit()  # Trigger the loaded event
	else:
		push_error("Failed to read from backup, using default data")


## Function to load the game data
func _load_game() -> void:
	# Load the main save file
	var load_data : Variant = _load_json_file(main_save_path)
	if load_data != null:
		loaded_data = load_data  # Store the data
		SignalsBus.game_loaded_event.emit()  # Trigger the loaded event
	else:
		push_warning("Failed to parse save file json, using backup save data")
		_restore_from_backup()  # Restore from backup if the main file fails to load
		
