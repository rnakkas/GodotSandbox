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

var button_selector_map : Dictionary[Button, TextureRect] = {}

func _ready() -> void:
	button_selector_map = {
		play_button : play_selector_icon,
		options_button : options_selector_icon,
		hi_scores_button : hi_scores_selector_icon,
		quit_button : quit_selector_icon
	}
	
	print(button_selector_map[play_button])
	
	if self.visible:
		play_button.grab_focus()

func _on_play_button_pressed() -> void:
	play_button_pressed.emit()

func _on_options_button_pressed() -> void:
	options_button_pressed.emit()

func _on_hi_scores_button_pressed() -> void:
	hi_scores_button_pressed.emit()

func _on_quit_button_pressed() -> void:
	quit_button_pressed.emit()

## Helper funcs
func _show_button_selected() -> void:
	print("s")
