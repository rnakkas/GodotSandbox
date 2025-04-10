class_name ui_layer extends CanvasLayer

@onready var main_menu_ui : main_menu = %main_menu
@onready var options_menu_ui : options_menu = %options_menu
@onready var pause_menu_ui : pause_menu = %pause_menu
@onready var player_hud_ui : player_hud = %player_hud
@onready var confirm_dialog_ui : confirm_dialog = %confirm_dialog

signal game_started()
signal returned_to_main_menu_from_game()

enum ui_type 
{
	MAIN_MENU,
	OPTIONS_MENU,
	PAUSE_MENU,
	PLAYER_HUD_UI,
	CONFIRM_DIALOG
}

var is_game_running : bool

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	## Turn visibility on for main menu
	main_menu_ui.visible = true
	
	## Turn visibility off for all other ui
	options_menu_ui.visible = false
	pause_menu_ui.visible = false
	player_hud_ui.visible = false
	confirm_dialog_ui.visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if !main_menu_ui.visible && !options_menu_ui.visible && !pause_menu_ui.visible:
			_toggle_ui(ui_type.PAUSE_MENU)
			get_tree().paused = true 


####

## Main menu
func _on_main_menu_play_button_pressed() -> void:
	game_started.emit()
	
	## Grab fresh player data on game start
	player_hud_ui.player_lives_value.text = "x " + str(PlayerData.player_lives)
	player_hud_ui.score_value.text = str(PlayerData.player_score).pad_zeros(8)
	
	_toggle_ui(ui_type.MAIN_MENU)
	_toggle_ui(ui_type.PLAYER_HUD_UI)
	
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
	confirm_dialog_ui.dialog_label_main.text = UiUtility.dialog_return_to_main_menu
	_toggle_ui(ui_type.CONFIRM_DIALOG)


func _on_pause_menu_quit_button_pressed() -> void:
	confirm_dialog_ui.dialog_label_main.text = UiUtility.dialog_quit
	_toggle_ui(ui_type.CONFIRM_DIALOG)


####

## Confirm return to main menu or quit dialog
func _on_confirm_dialog_yes_button_pressed(dialog_text: String) -> void:
	match dialog_text:
		UiUtility.dialog_return_to_main_menu:
			_toggle_ui(ui_type.CONFIRM_DIALOG)
			_toggle_ui(ui_type.PAUSE_MENU)
			_toggle_ui(ui_type.PLAYER_HUD_UI)
			_toggle_ui(ui_type.MAIN_MENU)
			
			get_tree().paused = false 
			is_game_running = false
			returned_to_main_menu_from_game.emit()
		
		UiUtility.dialog_quit:
			get_tree().call_deferred("quit")


func _on_confirm_dialog_no_button_pressed() -> void:
	_toggle_ui(ui_type.CONFIRM_DIALOG)
	pause_menu_ui.resume_button.grab_focus()
	

####

## Helper functions
func _toggle_ui(menu_type : ui_type) -> void:
	var ui_element : Variant
	
	match menu_type:
		ui_type.MAIN_MENU:
			ui_element = main_menu_ui
			ui_element.play_button.grab_focus()
		ui_type.OPTIONS_MENU:
			ui_element = options_menu_ui
			ui_element.sound_volume_slider.grab_focus()
		ui_type.PLAYER_HUD_UI:
			ui_element = player_hud_ui
		ui_type.PAUSE_MENU:
			ui_element = pause_menu_ui
			ui_element.resume_button.grab_focus()
		ui_type.CONFIRM_DIALOG:
			ui_element = confirm_dialog_ui
			ui_element.no_button.grab_focus()
		
	if ui_element:
		ui_element.visible = !ui_element.visible
		ui_element.process_mode = Node.PROCESS_MODE_ALWAYS if ui_element.visible else Node.PROCESS_MODE_DISABLED
