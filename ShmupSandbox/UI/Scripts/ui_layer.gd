class_name UiLayer extends CanvasLayer

@onready var main_menu : MainMenu = %main_menu
@onready var options_menu : OptionsMenu = %options_menu
@onready var pause_menu : PauseMenu = %pause_menu
@onready var player_hud : PlayerHud = %player_hud
@onready var confirm_dialog : ConfirmDialog = %confirm_dialog
@onready var continue_screen : ContinueScreen = %continue_screen
@onready var game_over_screen : GameOverScreen = %game_over_screen
@onready var hi_scores_menu : HiScoresMenu = %hi_scores_menu
@onready var name_entry_dialog  : NameEntryDialog = %name_entry_dialog

signal game_started()
signal kill_game_instance()

var is_game_running : bool

func _ready() -> void:
	_initialize_ui_scenes()
	_connect_to_signals()
	
func _initialize_ui_scenes() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	## Turn visibility on for main menu
	main_menu.visible = true
	
	## Turn visibility off for all other ui
	options_menu.visible = false
	pause_menu.visible = false
	player_hud.visible = false
	confirm_dialog.visible = false
	continue_screen.visible = false
	game_over_screen.visible = false
	hi_scores_menu.visible = false
	name_entry_dialog.visible = false

func _connect_to_signals() -> void:
	SignalsBus.player_lives_updated.connect(_on_player_lives_depleted)
	SignalsBus.player_pressed_pause_game.connect(_on_player_pauses_game)

####

## Main function to toggle the different ui's
func _toggle_ui(ui: Control) -> void:
	if ui is MainMenu: ## TODO: Remove when start screen is ready
		ui = main_menu
		ui.play_button.grab_focus()
	
	ui.visible = !ui.visible
	ui.process_mode = Node.PROCESS_MODE_ALWAYS if ui.visible else Node.PROCESS_MODE_DISABLED

####

## Pausing game
func _on_player_pauses_game() -> void:
	get_tree().paused = true
	_toggle_ui(pause_menu)


####

## Main menu
func _on_main_menu_play_button_pressed() -> void:
	game_started.emit()
	
	## Grab fresh player data on game start
	player_hud.player_lives_value.text = "x " + str(PlayerData.player_lives)
	player_hud.score_value.text = str(PlayerData.player_score).pad_zeros(8)
	
	_toggle_ui(main_menu)
	_toggle_ui(player_hud)
	
	is_game_running = true

func _on_main_menu_options_button_pressed() -> void:
	_toggle_ui(main_menu)
	_toggle_ui(options_menu)

func _on_main_menu_hi_scores_button_pressed() -> void:
	_toggle_ui(main_menu)
	_toggle_ui(hi_scores_menu)

func _on_main_menu_quit_button_pressed() -> void:
	get_tree().call_deferred("quit")


####

## Options menu
func _on_options_menu_back_button_pressed() -> void:
	if !is_game_running:
		_toggle_ui(options_menu)
		_toggle_ui(main_menu)
	else:
		_toggle_ui(options_menu)
		_toggle_ui(pause_menu)


####

## Pause menu
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


####

## Confirm return to main menu or quit dialog
func _on_confirm_dialog_yes_button_pressed(dialog_text: String) -> void:
	match dialog_text:
		UiUtility.dialog_return_to_main_menu:
			_toggle_ui(confirm_dialog)
			_toggle_ui(pause_menu)
			_toggle_ui(player_hud)
			_toggle_ui(main_menu)
			
			get_tree().paused = false 
			is_game_running = false
			kill_game_instance.emit()
		
		UiUtility.dialog_quit:
			get_tree().call_deferred("quit")


func _on_confirm_dialog_no_button_pressed() -> void:
	_toggle_ui(confirm_dialog)
	pause_menu.resume_button.grab_focus()


####

## Continue screen 
func _on_player_lives_depleted() -> void:
	if PlayerData.player_lives < 0:
		_toggle_ui(continue_screen)

func _on_continue_screen_no_button_pressed() -> void:
	_toggle_ui(continue_screen)

	if _is_player_score_in_top_ten():
		_toggle_ui(name_entry_dialog)
	else:
		_toggle_ui(game_over_screen)

	kill_game_instance.emit()

## Helper func to check for player current score vs top 10 hi scores
func _is_player_score_in_top_ten() -> bool:
	var is_in_top_ten : bool
	var hi_score_list_size : int = PlayerData.player_hi_scores_dictionaries.size()

	for score_entry : int in range(hi_score_list_size):
		if PlayerData.player_score > PlayerData.player_hi_scores_dictionaries[score_entry]["score"]:
			is_in_top_ten = true
			break;
	
	if PlayerData.player_score <= PlayerData.player_hi_scores_dictionaries[hi_score_list_size-1]["score"] :
		is_in_top_ten = false
	
	return is_in_top_ten


func _on_continue_screen_yes_button_pressed() -> void:
	_toggle_ui(continue_screen)
	player_hud.player_lives_value.text = "x " + str(PlayerData._player_max_lives)
	player_hud.score_value.text = str(PlayerData.player_score).pad_zeros(8)

####

## Game over screen
func _on_game_over_screen_game_over_screen_timed_out() -> void:
	_toggle_ui(game_over_screen)
	_toggle_ui(player_hud)
	_toggle_ui(hi_scores_menu)
	# kill_game_instance.emit()


####

## Hi Scores menu
func _on_hi_scores_menu_back_button_pressed() -> void:
	_toggle_ui(hi_scores_menu)
	_toggle_ui(main_menu)


####

## Name entry dialog
func _on_name_entry_dialog_ok_button_pressed() -> void:
	_toggle_ui(name_entry_dialog)
	_toggle_ui(game_over_screen)
