class_name main_menu extends Control

@onready var play_button: Button = %play_button
@onready var play_selector_icon : TextureRect = %play_selector_icon

@onready var options_button: Button = %options_button
@onready var options_selector_icon: TextureRect = %options_selector_icon

@onready var hi_scores_button: Button = %hi_scores_button
@onready var hi_scores_selector_icon : TextureRect = %hi_scores_selector_icon

@onready var quit_button: Button = %quit_button
@onready var quit_selector_icon : TextureRect = %quit_selector_icon

signal play_button_pressed()
signal options_button_pressed()
signal hi_scores_button_pressed()
signal quit_button_pressed()

enum ButtonType {
	PLAY,
	OPTIONS,
	HI_SCORES,
	QUIT
}

var button_selector_array : Array[TextureRect] = []

func _ready() -> void:
	button_selector_array.append_array(
		[
			play_selector_icon, 
			options_selector_icon,
			hi_scores_selector_icon,
			quit_selector_icon
		]
	)
	
	if self.visible:
		_focus_on_button(play_button, play_selector_icon)

func _on_play_button_pressed() -> void:
	play_button_pressed.emit()

func _on_options_button_pressed() -> void:
	options_button_pressed.emit()

func _on_hi_scores_button_pressed() -> void:
	hi_scores_button_pressed.emit()

func _on_quit_button_pressed() -> void:
	quit_button_pressed.emit()

## Helper funcs
func _focus_on_button(button : Button, icon : TextureRect) -> void:
	button.grab_focus()
	for i:int in range(button_selector_array.size()):
			if button_selector_array[i] != icon:
				button_selector_array[i].visible = false
