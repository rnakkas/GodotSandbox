class_name main_menu extends Control

@onready var play_button: Button = %play_button
@onready var options_button: Button = %options_button
@onready var hi_scores_button: Button = %hi_scores_button
@onready var quit_button: Button = %quit_button

signal play_button_pressed()
signal options_button_pressed()
signal hi_scores_button_pressed()
signal quit_button_pressed()

func _on_play_button_pressed() -> void:
	play_button_pressed.emit()

func _on_options_button_pressed() -> void:
	options_button_pressed.emit()

func _on_hi_scores_button_pressed() -> void:
	hi_scores_button_pressed.emit()

func _on_quit_button_pressed() -> void:
	quit_button_pressed.emit()
