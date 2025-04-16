class_name ContinueScreen extends Control

@onready var continue_time_left : Label = %time_left_label
@onready var tick_timer : Timer = $tick_timer
@onready var yes_button : Button = %yes_button
@onready var no_button : Button = %no_button

signal yes_button_pressed()
signal no_button_pressed()

var max_continue_time : int = 2
var continue_time : int
const tick_time : int = 1
var ui_elements_list : Array[Control] = []
var current_focused_button : Button

func _ready() -> void:
	_create_ui_elements_list()

####

## Helper funcs

func _create_ui_elements_list() -> void:
	ui_elements_list.append_array(
		[
			yes_button,
			no_button
		]
	)

func start_countdown() -> void:
	continue_time = max_continue_time
	continue_time_left.text = str(continue_time)
	tick_timer.wait_time = tick_time
	tick_timer.start()

####


func _on_tick_timer_timeout() -> void:
	continue_time -= tick_time
	
	if continue_time <= 0:
		await get_tree().create_timer(0.2).timeout
		_handle_countdown_end()
	
	continue_time_left.text = str(continue_time)
		
####

## Helper funcs

func _handle_countdown_end() -> void:
	tick_timer.stop()

	## Automatically press the button that is focused
	match current_focused_button:
		yes_button:
			_continue_game()
		no_button:
			_end_game()


func _continue_game() -> void:
	## Reset player lives to max
	PlayerData.set_player_lives_to_max()

	## Reduce player's current score by 10%
	PlayerData.player_score = int(round(PlayerData.player_score * 0.9)) ## Round off to neared int

	## Turn off the continue screen
	await UiUtility.selected_button_element_press_animation(yes_button)

	## Set hud values
	yes_button_pressed.emit()

	## Respawn player
	SignalsBus.continue_game_player_respawn_event()


func _end_game() -> void:
	## Display game over screen
	no_button_pressed.emit()

####


func _on_yes_button_pressed() -> void:
	_continue_game()
	

func _on_yes_button_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, yes_button)
	current_focused_button = yes_button

func _on_yes_button_mouse_entered() -> void:
	yes_button.grab_focus()


func _on_no_button_pressed() -> void:
	# Display game over screen -done, 
	# TODO: Take player to enter hi score screen if within top 10 hi scores, else return to main menu
	_end_game()

func _on_no_button_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, no_button)
	current_focused_button = no_button

func _on_no_button_mouse_entered() -> void:
	no_button.grab_focus()
