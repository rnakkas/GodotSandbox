class_name UiLayer extends CanvasLayer

@onready var simple_crt_filter : SimpleCrtFilter = %SimpleCRTFilter
@onready var start_screen : StartScreen = %start_screen
@onready var main_menu : MainMenu = %main_menu
@onready var options_menu : OptionsMenu = %options_menu
@onready var game_settings : GameSettings = %game_settings
@onready var display_settings : DisplaySettings = %display_settings
@onready var audio_settings : AudioSettings = %audio_settings
@onready var pause_menu : PauseMenu = %pause_menu
@onready var player_hud : PlayerHud = %player_hud
@onready var confirm_dialog : ConfirmDialog = %confirm_dialog
@onready var continue_screen : ContinueScreen = %continue_screen
@onready var game_over_screen : GameOverScreen = %game_over_screen
@onready var hi_scores_menu : HiScoresMenu = %hi_scores_menu
@onready var name_entry_dialog  : NameEntryDialog = %name_entry_dialog


signal game_started()
signal kill_game_instance()


################################################
#NOTE: Ready
################################################
func _ready() -> void:
	_initialize_ui_scenes()
	_connect_to_signals()

func _initialize_ui_scenes() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	var ui_layer_nodes : Array[Control] = []
	for node : Control in get_tree().get_nodes_in_group(UiUtility.ui_layer_nodes):
		ui_layer_nodes.append(node)

	# Turn visibility on for start screen and off for all other screens
	for ui_node : Control in ui_layer_nodes:
		if ui_node is StartScreen:
			ui_node.visible = true
		else:
			ui_node.visible = false


func _connect_to_signals() -> void:
	SignalsBus.player_lives_updated.connect(_on_player_lives_depleted)
	SignalsBus.player_pressed_pause_game.connect(_on_player_pauses_game)


################################################
#NOTE: Main function to toggle the different ui's
################################################
func _toggle_ui(ui: Control) -> void:
	ui.visible = !ui.visible
	ui.process_mode = Node.PROCESS_MODE_ALWAYS if ui.visible else Node.PROCESS_MODE_DISABLED


################################################
#NOTE: Pausing game
################################################
func _on_player_pauses_game() -> void:
	get_tree().paused = true
	_toggle_ui(pause_menu)


################################################
#NOTE: Start screen
################################################
func _on_start_screen_start_pressed() -> void:
	_toggle_ui(start_screen)
	_toggle_ui(main_menu)


################################################
#NOTE: Main menu
################################################
func _on_main_menu_play_button_pressed() -> void:
	game_started.emit()
	GameManager.is_game_running = true
	_toggle_ui(main_menu)
	_toggle_ui(player_hud)

func _on_main_menu_options_button_pressed() -> void:
	_toggle_ui(main_menu)
	_toggle_ui(options_menu)

func _on_main_menu_hi_scores_button_pressed() -> void:
	_toggle_ui(main_menu)
	_toggle_ui(hi_scores_menu)

func _on_main_menu_quit_button_pressed() -> void:
	get_tree().call_deferred("quit")


################################################
#NOTE: Options menu
################################################
func _on_options_menu_back_button_pressed() -> void:
	if !GameManager.is_game_running:
		_toggle_ui(options_menu)
		_toggle_ui(main_menu)
	else:
		_toggle_ui(options_menu)
		_toggle_ui(pause_menu)

func _on_options_menu_game_settings_button_pressed() -> void:
	_toggle_ui(options_menu)
	_toggle_ui(game_settings)

func _on_options_menu_display_settings_button_pressed() -> void:
	_toggle_ui(options_menu)
	_toggle_ui(display_settings)

func _on_options_menu_audio_settings_button_pressed() -> void:
	_toggle_ui(options_menu)
	_toggle_ui(audio_settings)


################################################
#NOTE: Game Settings
################################################
func _on_game_settings_back_button_pressed() -> void:
	_toggle_ui(game_settings)
	_toggle_ui(options_menu)


################################################
#NOTE: Display Settings
################################################
func _on_display_settings_back_button_pressed() -> void:
	_toggle_ui(display_settings)
	_toggle_ui(options_menu)

func _on_display_settings_crt_filter_changed(crt_value: bool) -> void:
	simple_crt_filter.visible = crt_value


################################################
#NOTE: Audio settings
################################################
func _on_audio_settings_back_button_pressed() -> void:
	_toggle_ui(audio_settings)
	_toggle_ui(options_menu)


################################################
#NOTE: Pause menu
################################################
func _on_pause_menu_resume_button_pressed() -> void:
	get_tree().paused = false
	_toggle_ui(pause_menu)


func _on_pause_menu_options_button_pressed() -> void:
	_toggle_ui(pause_menu)
	_toggle_ui(options_menu)


func _on_pause_menu_main_menu_button_pressed() -> void:
	confirm_dialog.dialog_label_main.text = UiUtility.dialog_return_to_main_menu
	_toggle_ui(confirm_dialog)


func _on_pause_menu_quit_button_pressed() -> void:
	confirm_dialog.dialog_label_main.text = UiUtility.dialog_quit
	_toggle_ui(confirm_dialog)


################################################
#NOTE: Confirm return to main menu or quit dialog
################################################
func _on_confirm_dialog_yes_button_pressed(dialog_text: String) -> void:
	match dialog_text:
		UiUtility.dialog_return_to_main_menu:
			_toggle_ui(confirm_dialog)
			_toggle_ui(pause_menu)
			_toggle_ui(player_hud)
			_toggle_ui(main_menu)
			
			get_tree().paused = false 
			GameManager.is_game_running = false
			kill_game_instance.emit()
		
		UiUtility.dialog_quit:
			get_tree().call_deferred("quit")


func _on_confirm_dialog_no_button_pressed() -> void:
	_toggle_ui(confirm_dialog)
	pause_menu.resume_button.grab_focus()


################################################
#NOTE: Continue screen 
################################################
func _on_player_lives_depleted() -> void:
	if GameManager.player_lives < 0:
		if GameManager.player_credits > 0:
			_toggle_ui(continue_screen)
		elif GameManager.player_credits <= 0:
			_handle_name_entry_or_game_over_logic()


func _on_continue_screen_no_button_pressed() -> void:
	_toggle_ui(continue_screen)
	_handle_name_entry_or_game_over_logic()


################################################
#NOTE: Helper func to check for player current score vs top 10 hi scores
################################################
func _is_player_score_in_top_ten() -> bool:
	var is_in_top_ten : bool
	var hi_score_list_size : int = GameManager.player_hi_scores_dictionaries.size()

	for score_entry : int in range(hi_score_list_size):
		if GameManager.player_score > GameManager.player_hi_scores_dictionaries[score_entry]["score"]:
			is_in_top_ten = true
			break;
	
	if GameManager.player_score <= GameManager.player_hi_scores_dictionaries[hi_score_list_size-1]["score"] :
		is_in_top_ten = false
	
	return is_in_top_ten


################################################
#NOTE: Helper func with logic to show name entry dialog or game over screen based on player score
################################################
func _handle_name_entry_or_game_over_logic() -> void:
	if _is_player_score_in_top_ten():
		_toggle_ui(name_entry_dialog)
	else:
		_toggle_ui(game_over_screen)

	GameManager.is_game_running = false
	kill_game_instance.emit()


################################################
#NOTE: Continue dialog
################################################
func _on_continue_screen_yes_button_pressed() -> void:
	_toggle_ui(continue_screen)
	player_hud.player_lives_value.text = "x " + str(GameManager._player_max_lives)
	player_hud.score_value.text = str(GameManager.player_score).pad_zeros(8)


################################################
#NOTE: Game over screen
################################################
func _on_game_over_screen_game_over_screen_timed_out() -> void:
	_toggle_ui(game_over_screen)
	_toggle_ui(player_hud)
	_toggle_ui(hi_scores_menu)


################################################
#NOTE: Hi Scores menu
################################################
func _on_hi_scores_menu_back_button_pressed() -> void:
	_toggle_ui(hi_scores_menu)
	_toggle_ui(main_menu)


################################################
#NOTE: Name entry dialog
################################################
func _on_name_entry_dialog_ok_button_pressed() -> void:
	_toggle_ui(name_entry_dialog)
	_toggle_ui(game_over_screen)
