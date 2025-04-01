class_name options_menu extends Control

signal back_to_main_menu_button_pressed()

func _on_back_button_pressed() -> void:
	back_to_main_menu_button_pressed.emit()
