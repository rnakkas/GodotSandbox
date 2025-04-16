class_name UiLayer extends CanvasLayer

@onready var main_menu : MainMenu = %main_menu
@onready var options_menu : OptionsMenu = %options_menu
@onready var pause_menu : PauseMenu = %pause_menu
@onready var player_hud : PlayerHud = %player_hud
@onready var confirm_dialog : ConfirmDialog = %confirm_dialog
@onready var continue_screen : ContinueScreen = %continue_screen
@onready var game_over_screen : GameOverScreen = %game_over_screen

signal game_started()
signal returned_to_main_menu_from_game()

enum ui_type 
{
	MAIN_MENU,
	OPTIONS_MENU,
	PAUSE_MENU,
	PLAYER_HUD,
	CONFIRM_DIALOG,
	CONTINUE_SCREEN,
	GAME_OVER_SCREEN
}

var is_game_running : bool

func _ready() -> void:
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

	SignalsBus.player_lives_depleted.connect(_on_player_lives_depleted)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if (
			!main_menu.visible && 
			!options_menu.visible && 
			!pause_menu.visible && 
			!continue_screen.visible && 
			!game_over_screen.visible
			):
				_toggle_ui(ui_type.PAUSE_MENU)
				get_tree().paused = true 


####

## Main menu
func _on_main_menu_play_button_pressed() -> void:
	game_started.emit()
	
	## Grab fresh player data on game start
	player_hud.player_lives_value.text = "x " + str(PlayerData.player_lives)
	player_hud.score_value.text = str(PlayerData.player_score).pad_zeros(8)
	
	_toggle_ui(ui_type.MAIN_MENU)
	_toggle_ui(ui_type.PLAYER_HUD)
	
	is_game_running = true

func _on_main_menu_options_button_pressed() -> void:
	_toggle_ui(ui_type.MAIN_MENU)
	_toggle_ui(ui_type.OPTIONS_MENU)

func _on_main_menu_hi_scores_button_pressed() -> void:
	print("show hi scores")

func _on_main_menu_quit_button_pressed() -> void:
	get_tree().call_deferred("quit")


####

## Options menu
func _on_options_menu_back_button_pressed() -> void:
	if !is_game_running:
		_toggle_ui(ui_type.OPTIONS_MENU)
		_toggle_ui(ui_type.MAIN_MENU)
	else:
		_toggle_ui(ui_type.OPTIONS_MENU)
		_toggle_ui(ui_type.PAUSE_MENU)


####

## Pause menu
func _on_pause_menu_resume_button_pressed() -> void:
	get_tree().paused = false
	_toggle_ui(ui_type.PAUSE_MENU)


func _on_pause_menu_options_button_pressed() -> void:
	_toggle_ui(ui_type.PAUSE_MENU)
	_toggle_ui(ui_type.OPTIONS_MENU)


func _on_pause_menu_main_menu_button_pressed() -> void:
	confirm_dialog.dialog_label_main.text = UiUtility.dialog_return_to_main_menu
	_toggle_ui(ui_type.CONFIRM_DIALOG)


func _on_pause_menu_quit_button_pressed() -> void:
	confirm_dialog.dialog_label_main.text = UiUtility.dialog_quit
	_toggle_ui(ui_type.CONFIRM_DIALOG)


####

## Confirm return to main menu or quit dialog
func _on_confirm_dialog_yes_button_pressed(dialog_text: String) -> void:
	match dialog_text:
		UiUtility.dialog_return_to_main_menu:
			_toggle_ui(ui_type.CONFIRM_DIALOG)
			_toggle_ui(ui_type.PAUSE_MENU)
			_toggle_ui(ui_type.PLAYER_HUD)
			_toggle_ui(ui_type.MAIN_MENU)
			
			get_tree().paused = false 
			is_game_running = false
			returned_to_main_menu_from_game.emit()
		
		UiUtility.dialog_quit:
			get_tree().call_deferred("quit")


func _on_confirm_dialog_no_button_pressed() -> void:
	_toggle_ui(ui_type.CONFIRM_DIALOG)
	pause_menu.resume_button.grab_focus()


####

## Continue screen 
func _on_player_lives_depleted() -> void:
	_toggle_ui(ui_type.CONTINUE_SCREEN)

func _on_continue_screen_no_button_pressed() -> void:
	_toggle_ui(ui_type.CONTINUE_SCREEN)
	_toggle_ui(ui_type.GAME_OVER_SCREEN)

func _on_continue_screen_yes_button_pressed() -> void:
	_toggle_ui(ui_type.CONTINUE_SCREEN)
	player_hud.player_lives_value.text = "x " + str(PlayerData._player_max_lives)
	player_hud.score_value.text = str(PlayerData.player_score).pad_zeros(8)

####

## Game over screen
func _on_game_over_screen_game_over_screen_timed_out() -> void:
	_toggle_ui(ui_type.GAME_OVER_SCREEN)
	_toggle_ui(ui_type.PLAYER_HUD)
	_toggle_ui(ui_type.MAIN_MENU)
	returned_to_main_menu_from_game.emit()

## Helper functions
func _toggle_ui(menu_type : ui_type) -> void:
	var ui_element : Variant
	
	match menu_type:
		ui_type.MAIN_MENU:
			ui_element = main_menu
			ui_element.play_button.grab_focus()
		ui_type.OPTIONS_MENU:
			ui_element = options_menu
			ui_element.sound_volume_slider.grab_focus()
		ui_type.PLAYER_HUD:
			ui_element = player_hud
		ui_type.PAUSE_MENU:
			ui_element = pause_menu
			ui_element.resume_button.grab_focus()
		ui_type.CONFIRM_DIALOG:
			ui_element = confirm_dialog
			ui_element.no_button.grab_focus()
		ui_type.CONTINUE_SCREEN:
			ui_element = continue_screen
			ui_element.start_countdown()
			ui_element.yes_button.grab_focus()
		ui_type.GAME_OVER_SCREEN:
			ui_element = game_over_screen
			ui_element.game_over_timer.start()
		
	if ui_element:
		ui_element.visible = !ui_element.visible
		ui_element.process_mode = Node.PROCESS_MODE_ALWAYS if ui_element.visible else Node.PROCESS_MODE_DISABLED
