class_name AudioSettings extends Control

@onready var master_label : Label = %master_label
@onready var master_volume_slider : HSlider = %master_volume_slider
@onready var sound_label : Label = %sound_label
@onready var sound_volume_slider : HSlider = %sound_volume_slider
@onready var music_label : Label = %music_label
@onready var music_volume_slider : HSlider = %music_volume_slider
@onready var back_button : Button = %back_button

var ui_elements_list : Array[Control] = []

signal back_button_pressed()

func _ready() -> void:
	_create_ui_elements_list()


func _create_ui_elements_list() -> void:
	for node : Control in get_tree().get_nodes_in_group(UiUtility.audio_settings_ui_nodes):
		ui_elements_list.append(node)
		_connect_to_group_signals(node)

func _connect_to_group_signals(node : Control) -> void:
	if node.has_signal(UiUtility.signal_focus_entered):
		node.focus_entered.connect(_on_element_focused)
	if node.has_signal(UiUtility.signal_mouse_entered):
		node.mouse_entered.connect(_on_element_focused_with_mouse.bind(node)) # Use 'bind' to pass source node as property
	if node is Button || node is TextureButton:
		node.pressed.connect(_on_button_pressed.bind(node))
	if node is HSlider:
		node.drag_started.connect(_on_volume_slider_drag_started)
		node.drag_ended.connect(_on_volume_slider_drag_ended)
		node.value_changed.connect(_on_volume_slider_value_changed)

####

## Signal connections
func _on_element_focused() -> void:
	for element in ui_elements_list:
		if element.has_focus():
			if element == master_volume_slider:
				UiUtility.highlight_selected_element(ui_elements_list, master_label)
			elif element == sound_volume_slider:
				UiUtility.highlight_selected_element(ui_elements_list, sound_label)
			elif element == music_volume_slider:
				UiUtility.highlight_selected_element(ui_elements_list, music_label)
			elif element == back_button:
				UiUtility.highlight_selected_element(ui_elements_list, back_button)


func _on_element_focused_with_mouse(node : Control) -> void:
	node.grab_focus()
	if node == master_volume_slider:
		UiUtility.highlight_selected_element(ui_elements_list, master_label)
	elif node == sound_volume_slider:
		UiUtility.highlight_selected_element(ui_elements_list, sound_label)
	elif node == music_volume_slider:
		UiUtility.highlight_selected_element(ui_elements_list, music_label)


func _on_button_pressed(node: Control) -> void:
	if node == back_button:
		await UiUtility.selected_button_element_press_animation(node)
		back_button_pressed.emit()

		# # Save game settings when back button is pressed
		# _update_game_manager()
		# _save_game_settings()

func _on_volume_slider_drag_started() -> void:
	print("started dragging")

func _on_volume_slider_drag_ended(value_changed:bool) -> void:
	if value_changed || !value_changed:
		print("drag ended")

func _on_volume_slider_value_changed(value: float) -> void:
	value = int(value)
	if master_volume_slider.has_focus():
		print("master volume: ", value)

func _on_visibility_changed() -> void:
	if self.visible:
		master_volume_slider.grab_focus()
