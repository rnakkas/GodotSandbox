class_name options_menu extends Control

signal back_to_main_menu_button_pressed()

func _on_return_to_main_menu_pressed() -> void:
	back_to_main_menu_button_pressed.emit()
