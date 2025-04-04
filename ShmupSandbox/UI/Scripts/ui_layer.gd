class_name ui_layer extends CanvasLayer

@onready var main_menu_ui : main_menu = %main_menu
@onready var options_menu_ui : options_menu = %options_menu
@onready var pause_menu_ui : pause_menu = %pause_menu
@onready var player_hud_ui : player_hud = %player_hud

signal game_started()
signal returned_to_main_menu_from_game()

enum UiType 
{
	MAIN_MENU,
	OPTIONS_MENU,
	PAUSE_MENU,
	PLAYER_HUD_UI
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

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if !main_menu_ui.visible && !options_menu_ui.visible && !pause_menu_ui.visible:
			_toggle_ui(UiType.PAUSE_MENU)
			get_tree().paused = true 


####

## Main menu
func _on_main_menu_play_button_pressed() -> void:
	_toggle_ui(UiType.MAIN_MENU)
	_toggle_ui(UiType.PLAYER_HUD_UI)
	is_game_running = true
	game_started.emit()

func _on_main_menu_options_button_pressed() -> void:
	_toggle_ui(UiType.MAIN_MENU)
	_toggle_ui(UiType.OPTIONS_MENU)

func _on_main_menu_hi_scores_button_pressed() -> void:
	print("show hi scores")

func _on_main_menu_quit_button_pressed() -> void:
	get_tree().call_deferred("quit")


####

## Options menu
func _on_options_menu_back_button_pressed() -> void:
	if !is_game_running:
		_toggle_ui(UiType.OPTIONS_MENU)
		_toggle_ui(UiType.MAIN_MENU)
	else:
		_toggle_ui(UiType.OPTIONS_MENU)
		_toggle_ui(UiType.PAUSE_MENU)


####

## Pause menu
func _on_pause_menu_resume_button_pressed() -> void:
	get_tree().paused = false
	_toggle_ui(UiType.PAUSE_MENU)


func _on_pause_menu_options_button_pressed() -> void:
	_toggle_ui(UiType.PAUSE_MENU)
	_toggle_ui(UiType.OPTIONS_MENU)


func _on_pause_menu_main_menu_button_pressed() -> void:
	_toggle_ui(UiType.PAUSE_MENU)
	_toggle_ui(UiType.MAIN_MENU)
	
	get_tree().paused = false 
	is_game_running = false
	returned_to_main_menu_from_game.emit()


func _on_pause_menu_quit_button_pressed() -> void:
	get_tree().call_deferred("quit")


####

## Helper functions
func _toggle_ui(menu_type : UiType) -> void:
	var ui_element : Variant
	
	match menu_type:
		UiType.MAIN_MENU:
			ui_element = main_menu_ui
			main_menu_ui.play_button.grab_focus()
		UiType.OPTIONS_MENU:
			ui_element = options_menu_ui
			options_menu_ui.sound_volume_slider.grab_focus()
		UiType.PLAYER_HUD_UI:
			ui_element = player_hud_ui
		UiType.PAUSE_MENU:
			ui_element = pause_menu_ui
		
	if ui_element:
		ui_element.visible = !ui_element.visible
		ui_element.process_mode = Node.PROCESS_MODE_ALWAYS if ui_element.visible else Node.PROCESS_MODE_DISABLED
		
		
