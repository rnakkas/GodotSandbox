class_name main extends Node2D

@onready var main_menu_ui : main_menu = %main_menu
@onready var options_menu_ui : options_menu = %options_menu
@onready var pause_menu_ui : pause_menu = %pause_menu
@onready var player_hud_ui : player_hud = %player_hud

enum UiType 
{
	MAIN_MENU,
	OPTIONS_MENU,
	PAUSE_MENU,
	PLAYER_HUD_UI
}

var game_scene : PackedScene = preload("res://ShmupSandbox/Main/Scenes/game.tscn")

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	## Turn visibility on for main menu
	main_menu_ui.visible = true
	
	## Turn visibility off for all other ui
	options_menu_ui.visible = false
	pause_menu_ui.visible = false
	player_hud_ui.visible = false
	

func _process(_delta: float) -> void:
	## For testing only
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("reset"):
		get_tree().paused = false
		get_tree().reload_current_scene()

## Main menu
func _on_main_menu_play_button_pressed() -> void:
	_toggle_ui(UiType.MAIN_MENU)
	_toggle_ui(UiType.PLAYER_HUD_UI)
	_start_game()

func _on_main_menu_options_button_pressed() -> void:
	_toggle_ui(UiType.MAIN_MENU)
	_toggle_ui(UiType.OPTIONS_MENU)

func _on_main_menu_hi_scores_button_pressed() -> void:
	print("show hi scores")

func _on_main_menu_quit_button_pressed() -> void:
	get_tree().call_deferred("quit")

## Options menu
func _on_options_menu_back_to_main_menu_button_pressed() -> void:
	_toggle_ui(UiType.OPTIONS_MENU)
	_toggle_ui(UiType.MAIN_MENU)

## Player hud
func _on_player_hud_pause_button_pressed() -> void:
	get_tree().paused = true
	_toggle_ui(UiType.PLAYER_HUD_UI)
	_toggle_ui(UiType.PAUSE_MENU)


## Helper functions
func _start_game() -> void:
	var game_instance := game_scene.instantiate()
	add_child(game_instance)

func _toggle_ui(menu_type : UiType) -> void:
	var ui_element : Variant
	
	match menu_type:
		UiType.MAIN_MENU:
			ui_element = main_menu_ui
		UiType.OPTIONS_MENU:
			ui_element = options_menu_ui
		UiType.PLAYER_HUD_UI:
			ui_element = player_hud_ui
		UiType.PAUSE_MENU:
			ui_element = pause_menu_ui
		_: null
		
	if ui_element:
		ui_element.visible = !ui_element.visible
		ui_element.process_mode = Node.PROCESS_MODE_ALWAYS if ui_element.visible else Node.PROCESS_MODE_DISABLED
		
