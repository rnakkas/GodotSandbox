class_name ContinueScreen extends Control

@onready var continue_time_left : Label = %time_left_label
@onready var tick_timer : Timer = $tick_timer
@onready var yes_button : Button = %yes_button
@onready var no_button : Button = %no_button

var continue_time : int = 10
const tick_time : int = 1
var ui_elements_list : Array[Control] = []

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
	continue_time_left.text = str(continue_time)
	tick_timer.wait_time = tick_time
	tick_timer.start()

####


func _on_tick_timer_timeout() -> void:
	continue_time -= tick_time
	
	if continue_time <= 0:
		tick_timer.stop()
	
	continue_time_left.text = str(continue_time)
		
####

func _on_yes_button_pressed() -> void:
	print("continue yes") # TODO: Reset lives to max, deduct score by 10%, respawn player
	PlayerData.set_player_lives_to_max()

func _on_yes_button_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, yes_button)

func _on_yes_button_mouse_entered() -> void:
	yes_button.grab_focus()


func _on_no_button_pressed() -> void:
	# TODO: Display game over screen, Take player to enter hi score screen if within top 10 hi scores, else return to main menu
	print("continue no") 

func _on_no_button_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, no_button)

func _on_no_button_mouse_entered() -> void:
	no_button.grab_focus()
