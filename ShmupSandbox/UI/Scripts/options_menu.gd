class_name OptionsMenu extends Control

## Gameplay options ##
@onready var gameplay_label : Label = %gameplay_label
@onready var lives_label : Label = %lives_label
@onready var lives_value : Label = %lives_value
@onready var credits_label : Label = %credits_label
@onready var credits_value : Label = %credits_value

## Display options ##
@onready var display_label : Label = %display_label
@onready var mode_label : Label = %mode_label
@onready var mode_value : Label = %mode_value
@onready var crt_filter_label : Label = %crt_filter_label
@onready var crt_filter_value : Label = %crt_filter_value

## Audio options ##
@onready var audio_label : Label = %audio_label
@onready var master_label : Label = %master_label
@onready var master_volume_slider : HSlider = %master_volume_slider
@onready var sound_label : Label = %sound_label
@onready var sound_volume_slider: HSlider = %sound_volume_slider
@onready var music_label : Label = %music_label
@onready var music_volume_slider: HSlider = %music_volume_slider

@onready var back_button: Button = %back_button

signal back_button_pressed()

var ui_elements_list : Array[Control] = []

func _ready() -> void:
	_create_ui_elements_list()


## Helper funcs
####

## Helper funcs
func _create_ui_elements_list() -> void:
	for node : Control in get_tree().get_nodes_in_group("options_ui_nodes"):
		ui_elements_list.append(node)
		_connect_to_group_signals(node)
	print(ui_elements_list, "\n")

func _connect_to_group_signals(node : Control) -> void:
	if node.has_signal("focus_entered"):
		node.focus_entered.connect(_on_element_focused)
	if node.has_signal("mouse_entered"):
		# Use 'bind' to know which node emitted the mouse_entered signal
		node.mouse_entered.connect(_on_element_focused_with_mouse.bind(node)) 
	if node is Button:
		node.pressed.connect(_on_back_button_pressed)

####
## Signal connections

func _on_element_focused() -> void:
	_check_for_focused_element()

func _on_element_focused_with_mouse(node : Control) -> void:
	node.grab_focus()

func _check_for_focused_element() -> void:
		for element : int in range(ui_elements_list.size()):
			if ui_elements_list[element].has_focus():
				UiUtility.highlight_selected_element(ui_elements_list, ui_elements_list[element])


func _on_back_button_pressed() -> void:
	await UiUtility.selected_button_element_press_animation(back_button)
	back_button_pressed.emit()


# ## Sliders
# func _on_sound_volume_slider_focus_entered() -> void:
# 	UiUtility.highlight_selected_element(ui_elements_list, sound_label)

# func _on_sound_volume_slider_mouse_entered() -> void:
# 	sound_volume_slider.grab_focus()

# func _on_music_volume_slider_focus_entered() -> void:
# 	UiUtility.highlight_selected_element(ui_elements_list, music_label)

# func _on_music_volume_slider_mouse_entered() -> void:
# 	music_volume_slider.grab_focus()

# # func _on_screen_shake_amount_slider_focus_entered() -> void:
# # 	UiUtility.highlight_selected_element(ui_elements_list, screen_shake_label)

# # func _on_screen_shake_amount_slider_mouse_entered() -> void:
# # 	screen_shake_amount_slider.grab_focus()


# ## Back button
# func _on_back_button_focus_entered() -> void:
# 	UiUtility.highlight_selected_element(ui_elements_list, back_button)

# func _on_back_button_pressed() -> void:
# 	await UiUtility.selected_button_element_press_animation(back_button)
# 	back_button_pressed.emit()

# func _on_back_button_mouse_entered() -> void:
# 	back_button.grab_focus()


func _on_visibility_changed() -> void:
	if self.visible:
		gameplay_label.grab_focus()
