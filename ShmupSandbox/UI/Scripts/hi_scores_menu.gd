class_name HiScoresMenu extends Control

@onready var back_button : Button = %back_button

signal back_button_pressed()

func _on_back_button_pressed() -> void:
	await UiUtility.selected_button_element_press_animation(back_button)
	back_button_pressed.emit()

func _on_back_button_mouse_entered() -> void:
	back_button.grab_focus()

func _on_back_button_focus_entered() -> void:
	UiUtility.highlight_selected_element([back_button], back_button)
