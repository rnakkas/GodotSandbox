class_name options_menu extends Control

@onready var sound_volume_slider: HSlider = %sound_volume_slider
@onready var music_volume_slider: HSlider = %music_volume_slider
@onready var screen_shake_amount_slider: HSlider = %screen_shake_amount_slider
@onready var back_button: Button = %back_button
@onready var back_selector_icon: TextureRect = %back_selector_icon


signal back_button_pressed()


func _on_sound_volume_slider_focus_entered() -> void:
	back_selector_icon.visible = false

func _on_music_volume_slider_focus_entered() -> void:
	back_selector_icon.visible = false

func _on_screen_shake_amount_slider_focus_entered() -> void:
	back_selector_icon.visible = false

func _on_back_button_focus_entered() -> void:
	back_selector_icon.visible = true

func _on_back_button_pressed() -> void:
	back_button_pressed.emit()
