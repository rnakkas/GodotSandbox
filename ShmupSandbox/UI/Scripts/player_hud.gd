class_name player_hud extends Control

signal pause_button_pressed()


func _on_pause_button_pressed() -> void:
	pause_button_pressed.emit()
