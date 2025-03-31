class_name main extends Node2D

@onready var main_menu_ui : main_menu = %main_menu
@onready var options_menu_ui : options_menu = %options_menu

enum MenuType 
{
	MAIN_MENU,
	OPTIONS_MENU
}

var game_scene : PackedScene = preload("res://ShmupSandbox/Main/Scenes/game.tscn")

func _ready() -> void:
	## Turn visibility on for main menu
	main_menu_ui.visible = true
	
	## Turn visibility off for all other ui
	options_menu_ui.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func _on_main_menu_play_button_pressed() -> void:
	_toggle_menu(MenuType.MAIN_MENU)
	_start_game()


func _on_main_menu_options_button_pressed() -> void:
	_toggle_menu(MenuType.MAIN_MENU)
	_toggle_menu(MenuType.OPTIONS_MENU)


func _on_main_menu_hi_scores_button_pressed() -> void:
	print("show hi scores")

func _on_main_menu_quit_button_pressed() -> void:
	get_tree().call_deferred("quit")


func _on_options_menu_back_to_main_menu_button_pressed() -> void:
	_toggle_menu(MenuType.OPTIONS_MENU)
	_toggle_menu(MenuType.MAIN_MENU)


func _start_game() -> void:
	var game_instance := game_scene.instantiate()
	add_child(game_instance)


func _toggle_menu(menu_type : MenuType) -> void:
	match menu_type:
		MenuType.MAIN_MENU:
			main_menu_ui.visible = !main_menu_ui.visible
			if (main_menu_ui.visible):
				main_menu_ui.process_mode = Node.PROCESS_MODE_ALWAYS
			else:
				main_menu_ui.process_mode = Node.PROCESS_MODE_DISABLED
		
		MenuType.OPTIONS_MENU:
			options_menu_ui.visible = !options_menu_ui.visible
			if (options_menu_ui.visible):
				options_menu_ui.process_mode = Node.PROCESS_MODE_ALWAYS
			else:
				options_menu_ui.process_mode = Node.PROCESS_MODE_DISABLED
		
