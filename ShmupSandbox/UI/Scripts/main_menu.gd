class_name MainMenu extends Control

@onready var play_button: Button = %play_button
@onready var options_button: Button = %options_button
@onready var hi_scores_button: Button = %hi_scores_button
@onready var quit_button: Button = %quit_button

signal play_button_pressed()
signal options_button_pressed()
signal hi_scores_button_pressed()
signal quit_button_pressed()

var ui_elements_list : Array[Control] = []

func _ready() -> void:
	_create_ui_elements_list()
	
	if self.visible:
		play_button.call_deferred("grab_focus")

####

## Helper funcs

func _create_ui_elements_list() -> void:
	ui_elements_list.append_array(
		[
			play_button,
			options_button,
			hi_scores_button,
			quit_button
		]
	)

####

## Play button
func _on_play_button_pressed() -> void:
	await UiUtility.selected_button_element_press_animation(play_button)
	play_button_pressed.emit()


func _on_play_button_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, play_button)

func _on_play_button_mouse_entered() -> void:
	play_button.grab_focus()


## Options button
func _on_options_button_pressed() -> void:
	await UiUtility.selected_button_element_press_animation(options_button)
	options_button_pressed.emit()

func _on_options_button_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, options_button)

func _on_options_button_mouse_entered() -> void:
	options_button.grab_focus()


## Hi scores button
func _on_hi_scores_button_pressed() -> void:
	await UiUtility.selected_button_element_press_animation(hi_scores_button)
	hi_scores_button_pressed.emit()

func _on_hi_scores_button_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, hi_scores_button)

func _on_hi_scores_button_mouse_entered() -> void:
	hi_scores_button.grab_focus()


## Quit button
func _on_quit_button_pressed() -> void:
	await UiUtility.selected_button_element_press_animation(quit_button)
	quit_button_pressed.emit()

func _on_quit_button_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, quit_button)

func _on_quit_button_mouse_entered() -> void:
	quit_button.grab_focus()
