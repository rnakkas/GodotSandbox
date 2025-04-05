class_name options_menu extends Control

@onready var sound_label : Label = %sound_label
@onready var sound_volume_slider: HSlider = %sound_volume_slider

@onready var music_label : Label = %music_label
@onready var music_volume_slider: HSlider = %music_volume_slider

@onready var screen_shake_label : Label = %screen_shake_label
@onready var screen_shake_amount_slider: HSlider = %screen_shake_amount_slider

@onready var back_button: Button = %back_button
@onready var back_selector_icon: TextureRect = %back_selector_icon

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


func _highlight_selected_element(ui_element : Control) -> void:
	for i:int in range(ui_elements_list.size()):
		if ui_elements_list[i] == ui_element:
			Utility.highlight_ui_elment(ui_elements_list[i])
		else:
			Utility.remove_highlight_from_ui_element(ui_elements_list[i])


####
## Signal connections

func _on_sound_volume_slider_focus_entered() -> void:
	back_selector_icon.visible = false
	_highlight_selected_element(sound_label)

func _on_music_volume_slider_focus_entered() -> void:
	back_selector_icon.visible = false
	_highlight_selected_element(music_label)

func _on_screen_shake_amount_slider_focus_entered() -> void:
	back_selector_icon.visible = false
	_highlight_selected_element(screen_shake_label)

func _on_back_button_focus_entered() -> void:
	back_selector_icon.visible = false
	_highlight_selected_element(back_button) #### TODO: Fix this

func _on_back_button_pressed() -> void:
	back_button_pressed.emit()
