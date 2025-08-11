class_name UiLayer extends CanvasLayer

@onready var simple_crt_filter: SimpleCrtFilter = %SimpleCRTFilter

var ui_layer_nodes: Array[Control] = []

signal game_started()
signal kill_game_instance()


################################################
# Ready
################################################
func _ready() -> void:
	_initialize_ui_scenes()
	_connect_to_global_signals()
	_connect_to_ui_signals()

func _initialize_ui_scenes() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# var ui_layer_nodes: Array[Control] = []
	for node: Control in get_tree().get_nodes_in_group(UiUtility.ui_layer_nodes):
		ui_layer_nodes.append(node)

	# Turn visibility on for start screen and off for all other screens
	for ui_node: Control in ui_layer_nodes:
		if ui_node is StartScreen:
			ui_node.visible = true
		else:
			ui_node.visible = false
		_set_process_mode(ui_node)


func _connect_to_global_signals() -> void:
	SignalsBus.player_lives_updated_event.connect(self._on_player_lives_depleted)
	SignalsBus.player_pressed_pause_game_event.connect(self._on_player_pauses_game)
	SignalsBus.boss_incoming_warning_event.connect(self._on_boss_incoming_warning_event)
	SignalsBus.boss_warning_ended_event.connect(self._on_boss_warning_ended)
	SignalsBus.boss_sequence_ended_event.connect(self._on_boss_sequence_ended)


func _connect_to_ui_signals() -> void:
	for ui_node: Control in ui_layer_nodes:
		if ui_node is StartScreen:
			ui_node.start_pressed.connect(self._on_start_screen_start_pressed)
		
		if ui_node is MainMenu:
			ui_node.play_button_pressed.connect(self._on_main_menu_play_button_pressed)
			ui_node.options_button_pressed.connect(self._on_main_menu_options_button_pressed)
			ui_node.hi_scores_button_pressed.connect(self._on_main_menu_hi_scores_button_pressed)
			ui_node.quit_button_pressed.connect(self._on_main_menu_quit_button_pressed)
		
		if ui_node is OptionsMenu:
			ui_node.back_button_pressed.connect(self._on_options_menu_back_button_pressed)
			ui_node.game_settings_button_pressed.connect(self._on_options_menu_game_settings_button_pressed)
			ui_node.display_settings_button_pressed.connect(self._on_options_menu_display_settings_button_pressed)
			ui_node.audio_settings_button_pressed.connect(self._on_options_menu_audio_settings_button_pressed)
		
		if ui_node is GameSettings:
			ui_node.back_button_pressed.connect(self._on_game_settings_back_button_pressed)
		
		if ui_node is DisplaySettings:
			ui_node.back_button_pressed.connect(self._on_display_settings_back_button_pressed)
			ui_node.crt_filter_changed.connect(self._on_display_settings_crt_filter_changed)
		
		if ui_node is AudioSettings:
			ui_node.back_button_pressed.connect(self._on_audio_settings_back_button_pressed)
		
		if ui_node is PauseMenu:
			ui_node.resume_button_pressed.connect(self._on_pause_menu_resume_button_pressed)
			ui_node.options_button_pressed.connect(self._on_pause_menu_options_button_pressed)
			ui_node.main_menu_button_pressed.connect(self._on_pause_menu_main_menu_button_pressed)
			ui_node.quit_button_pressed.connect(self._on_pause_menu_quit_button_pressed)
		
		if ui_node is ConfirmDialog:
			ui_node.yes_button_pressed.connect(self._on_confirm_dialog_yes_button_pressed)
			ui_node.no_button_pressed.connect(self._on_confirm_dialog_no_button_pressed)
		
		if ui_node is ContinueScreen:
			ui_node.yes_button_pressed.connect(self._on_continue_screen_yes_button_pressed)
			ui_node.no_button_pressed.connect(self._on_continue_screen_no_button_pressed)
		
		if ui_node is GameOverScreen:
			ui_node.game_over_screen_timed_out.connect(self._on_game_over_screen_game_over_screen_timed_out)
		
		if ui_node is HiScoresMenu:
			ui_node.back_button_pressed.connect(self._on_hi_scores_menu_back_button_pressed)
		
		if ui_node is NameEntryDialog:
			ui_node.ok_button_pressed.connect(self._on_name_entry_dialog_ok_button_pressed)


################################################
# Helper func to set process mode for the ui node
################################################
func _set_process_mode(ui_node: Control) -> void:
	if ui_node is BossWarningUi or ui_node is StageClearScreen:
		ui_node.process_mode = Node.PROCESS_MODE_PAUSABLE
	else:
		ui_node.process_mode = Node.PROCESS_MODE_ALWAYS if ui_node.visible else Node.PROCESS_MODE_DISABLED

################################################
#NOTE: Pausing game
################################################
func _on_player_pauses_game() -> void:
	get_tree().paused = true
	# _toggle_ui(pause_menu)
	for ui: Control in ui_layer_nodes:
		if ui is PauseMenu:
			ui.visible = true
		_set_process_mode(ui)


################################################
#NOTE: Start screen
################################################
func _on_start_screen_start_pressed() -> void:
	# _toggle_ui(start_screen)
	# _toggle_ui(main_menu)
	for ui: Control in ui_layer_nodes:
		if ui is StartScreen:
			ui.visible = false
		if ui is MainMenu:
			ui.visible = true
		_set_process_mode(ui)


################################################
#NOTE: Main menu
################################################
func _on_main_menu_play_button_pressed() -> void:
	game_started.emit()
	GameManager.is_game_running = true

	for ui: Control in ui_layer_nodes:
		if ui is MainMenu:
			ui.visible = false
		if ui is PlayerHud:
			ui.visible = true
		_set_process_mode(ui)

func _on_main_menu_options_button_pressed() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is MainMenu:
			ui.visible = false
		if ui is OptionsMenu:
			ui.visible = true
		_set_process_mode(ui)

func _on_main_menu_hi_scores_button_pressed() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is MainMenu:
			ui.visible = false
		if ui is HiScoresMenu:
			ui.visible = true
		_set_process_mode(ui)

func _on_main_menu_quit_button_pressed() -> void:
	get_tree().call_deferred("quit")


################################################
#NOTE: Options menu
################################################
func _on_options_menu_back_button_pressed() -> void:
	if !GameManager.is_game_running:
		for ui: Control in ui_layer_nodes:
			if ui is OptionsMenu:
				ui.visible = false
			if ui is MainMenu:
				ui.visible = true
			_set_process_mode(ui)
	else:
		for ui: Control in ui_layer_nodes:
			if ui is OptionsMenu:
				ui.visible = false
			if ui is PauseMenu:
				ui.visible = true
			_set_process_mode(ui)

func _on_options_menu_game_settings_button_pressed() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is OptionsMenu:
			ui.visible = false
		if ui is GameSettings:
			ui.visible = true
		_set_process_mode(ui)

func _on_options_menu_display_settings_button_pressed() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is OptionsMenu:
			ui.visible = false
		if ui is DisplaySettings:
			ui.visible = true
		_set_process_mode(ui)

func _on_options_menu_audio_settings_button_pressed() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is OptionsMenu:
			ui.visible = false
		if ui is AudioSettings:
			ui.visible = true
		_set_process_mode(ui)


################################################
#NOTE: Game Settings
################################################
func _on_game_settings_back_button_pressed() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is GameSettings:
			ui.visible = false
		if ui is OptionsMenu:
			ui.visible = true
		_set_process_mode(ui)


################################################
#NOTE: Display Settings
################################################
func _on_display_settings_back_button_pressed() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is DisplaySettings:
			ui.visible = false
		if ui is OptionsMenu:
			ui.visible = true
		_set_process_mode(ui)

func _on_display_settings_crt_filter_changed(crt_value: bool) -> void:
	simple_crt_filter.visible = crt_value


################################################
#NOTE: Audio settings
################################################
func _on_audio_settings_back_button_pressed() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is AudioSettings:
			ui.visible = false
		if ui is OptionsMenu:
			ui.visible = true
		_set_process_mode(ui)


################################################
#NOTE: Pause menu
################################################
func _on_pause_menu_resume_button_pressed() -> void:
	get_tree().paused = false
	for ui: Control in ui_layer_nodes:
		if ui is PauseMenu:
			ui.visible = false
		_set_process_mode(ui)


func _on_pause_menu_options_button_pressed() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is PauseMenu:
			ui.visible = false
		if ui is OptionsMenu:
			ui.visible = true
		_set_process_mode(ui)


func _on_pause_menu_main_menu_button_pressed() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is ConfirmDialog:
			ui.dialog_label_main.text = UiUtility.dialog_return_to_main_menu
			ui.visible = true
		_set_process_mode(ui)


func _on_pause_menu_quit_button_pressed() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is ConfirmDialog:
			ui.dialog_label_main.text = UiUtility.dialog_quit
			ui.visible = true
		_set_process_mode(ui)


################################################
#NOTE: Confirm return to main menu or quit dialog
################################################
func _on_confirm_dialog_yes_button_pressed(dialog_text: String) -> void:
	match dialog_text:
		UiUtility.dialog_return_to_main_menu:
			for ui: Control in ui_layer_nodes:
				if ui is ConfirmDialog:
					ui.visible = false
				if ui is PauseMenu:
					ui.visible = false
				if ui is PlayerHud:
					ui.visible = false
				if ui is MainMenu:
					ui.visible = true
				_set_process_mode(ui)
			
			get_tree().paused = false
			GameManager.is_game_running = false
			kill_game_instance.emit()
		
		UiUtility.dialog_quit:
			get_tree().call_deferred("quit")


func _on_confirm_dialog_no_button_pressed() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is ConfirmDialog:
			ui.visible = false
		if ui is PauseMenu:
			ui.resume_button.grab_focus()
		_set_process_mode(ui)


################################################
#NOTE: Continue screen 
################################################
func _on_player_lives_depleted() -> void:
	if GameManager.player_lives < 0:
		if GameManager.player_credits > 0:
			for ui: Control in ui_layer_nodes:
				if ui is ContinueScreen:
					ui.visible = true
				_set_process_mode(ui)
		elif GameManager.player_credits <= 0:
			# _handle_name_entry_or_game_over_logic()
			for ui: Control in ui_layer_nodes:
				if ui is PlayerHud:
					ui.visible = false
				if ui is GameOverScreen:
					ui.visible = true
				_set_process_mode(ui)


func _on_continue_screen_yes_button_pressed() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is ContinueScreen:
			ui.visible = false
		if ui is PlayerHud:
			ui.player_lives_value.text = "x " + str(GameManager._player_max_lives)
			ui.score_value.text = str(GameManager.player_score)
		_set_process_mode(ui)


func _on_continue_screen_no_button_pressed() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is ContinueScreen:
			ui.visible = false
		_set_process_mode(ui)
	_handle_name_entry_or_game_over_logic()


################################################
# Helper func with logic to show name entry dialog or game over screen based on player score
################################################
func _handle_name_entry_or_game_over_logic() -> void:
	if _is_player_score_in_top_ten():
		for ui: Control in ui_layer_nodes:
			if ui is NameEntryDialog:
				ui.visible = true
			_set_process_mode(ui)
	else:
		for ui: Control in ui_layer_nodes:
			if ui is MainMenu:
				ui.visible = true
			_set_process_mode(ui)

	GameManager.is_game_running = false
	kill_game_instance.emit()


################################################
# Helper func to check for player current score vs top 10 hi scores
################################################
func _is_player_score_in_top_ten() -> bool:
	var is_in_top_ten: bool
	var hi_score_list_size: int = GameManager.player_hi_scores_dictionaries.size()

	for score_entry: int in range(hi_score_list_size):
		if GameManager.player_score > GameManager.player_hi_scores_dictionaries[score_entry]["score"]:
			is_in_top_ten = true
			break ;
	
	if GameManager.player_score <= GameManager.player_hi_scores_dictionaries[hi_score_list_size - 1]["score"]:
		is_in_top_ten = false
	
	return is_in_top_ten


################################################
#NOTE: Game over screen
################################################
func _on_game_over_screen_game_over_screen_timed_out() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is GameOverScreen:
			ui.visible = false
		# if ui is PlayerHud:
		# 	ui.visible = false
		# if ui is HiScoresMenu:
		# 	ui.visible = true
		_handle_name_entry_or_game_over_logic()
		_set_process_mode(ui)


################################################
#NOTE: Hi Scores menu
################################################
func _on_hi_scores_menu_back_button_pressed() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is HiScoresMenu:
			ui.visible = false
		if ui is MainMenu:
			ui.visible = true
		_set_process_mode(ui)


################################################
#NOTE: Name entry dialog
################################################
func _on_name_entry_dialog_ok_button_pressed() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is NameEntryDialog:
			ui.visible = false
		if ui is HiScoresMenu:
			ui.visible = true
		_set_process_mode(ui)


################################################
# Boss warning ui
################################################
func _on_boss_incoming_warning_event(_boss_message: String) -> void:
	for ui: Control in ui_layer_nodes:
		if ui is BossWarningUi:
			ui.visible = true
			

func _on_boss_warning_ended() -> void:
	for ui: Control in ui_layer_nodes:
		if ui is BossWarningUi:
			ui.visible = false


################################################
# Stage clear screen
################################################
func _on_boss_sequence_ended(_boss: Node, _boss_killed: bool, _kill_score: int) -> void:
	for ui: Control in ui_layer_nodes:
		if ui is StageClearScreen:
			await get_tree().create_timer(3.0).timeout
			ui.visible = true
		_set_process_mode(ui)
