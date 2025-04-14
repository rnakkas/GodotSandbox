class_name OptionsMenu extends Control

@onready var sound_label : Label = %sound_label
@onready var sound_volume_slider: HSlider = %sound_volume_slider

@onready var music_label : Label = %music_label
@onready var music_volume_slider: HSlider = %music_volume_slider

@onready var screen_shake_label : Label = %screen_shake_label
@onready var screen_shake_amount_slider: HSlider = %screen_shake_amount_slider

@onready var back_button: Button = %back_button

signal back_button_pressed()

var ui_elements_list : Array[Control] = []

func _ready() -> void:
	create_ui_elements_list()


## Helper funcs
####

## Helper funcs
func create_ui_elements_list() -> void:
	ui_elements_list.append_array(
		[
			sound_label,
			music_label,
			screen_shake_label,
			back_button
		]
	)


####
## Signal connections

## Sliders
func _on_sound_volume_slider_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, sound_label)

func _on_sound_volume_slider_mouse_entered() -> void:
	sound_volume_slider.grab_focus()

func _on_music_volume_slider_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, music_label)

func _on_music_volume_slider_mouse_entered() -> void:
	music_volume_slider.grab_focus()

func _on_screen_shake_amount_slider_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, screen_shake_label)

func _on_screen_shake_amount_slider_mouse_entered() -> void:
	screen_shake_amount_slider.grab_focus()


## Back button
func _on_back_button_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, back_button)

func _on_back_button_pressed() -> void:
	await UiUtility.selected_button_element_press_animation(back_button)
	back_button_pressed.emit()

func _on_back_button_mouse_entered() -> void:
	back_button.grab_focus()
