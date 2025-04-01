class_name pause_menu extends Control

signal resume_button_pressed()
signal options_button_pressed()
signal main_menu_button_pressed()
signal quit_button_pressed()


func _on_resume_button_pressed() -> void:
	print("resume game")
	resume_button_pressed.emit()


func _on_options_button_pressed() -> void:
	options_button_pressed.emit()


func _on_main_menu_button_pressed() -> void:
	main_menu_button_pressed.emit()


func _on_quit_button_pressed() -> void:
	quit_button_pressed.emit()
