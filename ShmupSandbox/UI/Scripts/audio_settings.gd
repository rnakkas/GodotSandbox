class_name AudioSettings extends Control

@onready var master_label : Label = %master_label
@onready var master_value_hbox : HBoxContainer = %HBoxContainer_master_value
@onready var master_left_button : TextureButton = %master_left_button
@onready var master_value : Label = %master_value
@onready var master_right_button : TextureButton = %master_right_button

@onready var sound_label : Label = %sound_label
@onready var sound_value_hbox : HBoxContainer = %HBoxContainer_sound_value
@onready var sound_left_button : TextureButton = %sound_left_button
@onready var sound_value : Label = %sound_value
@onready var sound_right_button : TextureButton = %sound_right_button

@onready var music_label : Label = %music_label
@onready var music_value_hbox : HBoxContainer = %HBoxContainer_music_value
@onready var music_left_button : TextureButton = %music_left_button
@onready var music_value : Label = %music_value
@onready var music_right_button : TextureButton = %music_right_button

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

####

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left") || event.is_action_pressed("ui_left"):
		## Decrease master
		if master_label.has_focus():
			await UiUtility.arrow_buttons_press_animation(master_left_button)
			# _update_value(master_value, allowed_values_lives, -1)

		## Decrease sound
		if sound_label.has_focus():
			await UiUtility.arrow_buttons_press_animation(sound_left_button)
			# _update_value(sound_value, allowed_values_credits, -1)
		
		## Decrease music
		if music_label.has_focus():
			await UiUtility.arrow_buttons_press_animation(music_left_button)
			# _update_value(music_value, allowed_values_credits, -1)
			
	if event.is_action_pressed("move_right") || event.is_action_pressed("ui_right"):
		## Increase master
		if master_label.has_focus():
			await UiUtility.arrow_buttons_press_animation(master_right_button)
			# _update_value(lives_value, allowed_values_lives, 1)

		## Increase sound
		if sound_label.has_focus():
			await UiUtility.arrow_buttons_press_animation(sound_right_button)
			# _update_value(credits_value, allowed_values_credits, 1)
		
		## Increase music
		if music_label.has_focus():
			await UiUtility.arrow_buttons_press_animation(music_right_button)
			# _update_value(music_value, allowed_values_credits, 1)

####

## Signal connections
func _on_element_focused() -> void:
	for element in ui_elements_list:
		if element.has_focus():
			UiUtility.highlight_selected_element(ui_elements_list, element)


func _on_element_focused_with_mouse(node : Control) -> void:
	if node == master_left_button || node == master_right_button || node == master_value_hbox:
		master_label.grab_focus()
	elif node == sound_left_button || node == sound_right_button || node == sound_value_hbox:
		sound_label.grab_focus()
	elif node == music_left_button || node == music_right_button || node == music_value_hbox:
		music_label.grab_focus()
	else:
		node.grab_focus()


func _on_button_pressed(node: Control) -> void:
	match node:
		back_button:
			await UiUtility.selected_button_element_press_animation(node)
			back_button_pressed.emit()

			# # Save game settings when back button is pressed
			# _update_game_manager()
			# _save_game_settings()
		
		master_left_button:
			master_label.grab_focus()
			await UiUtility.arrow_buttons_press_animation(master_left_button)
			# _update_value(master_value, allowed_values_lives, -1)
		
		master_right_button:
			master_label.grab_focus()
			await UiUtility.arrow_buttons_press_animation(master_right_button)
			# _update_value(master_value, allowed_values_lives, 1)
		
		sound_left_button:
			sound_label.grab_focus()
			await UiUtility.arrow_buttons_press_animation(sound_left_button)
			# _update_value(sound_value, allowed_values_credits, -1)
		
		sound_right_button:
			sound_label.grab_focus()
			await UiUtility.arrow_buttons_press_animation(sound_right_button)
			# _update_value(sound_value, allowed_values_credits, 1)
		
		music_left_button:
			music_label.grab_focus()
			await UiUtility.arrow_buttons_press_animation(music_left_button)
			# _update_value(music_value, allowed_values_credits, -1)
		
		music_right_button:
			music_label.grab_focus()
			await UiUtility.arrow_buttons_press_animation(music_right_button)
			# _update_value(music_value, allowed_values_credits, 1)

		_:
			push_error("Unhandled button pressed: ", node.name)


func _on_visibility_changed() -> void:
	if self.visible:
		master_label.grab_focus()
