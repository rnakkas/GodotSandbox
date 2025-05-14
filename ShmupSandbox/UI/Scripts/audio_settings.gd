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
var volume_tick : int = 5

signal back_button_pressed()


################################################
#NOTE: Ready
################################################
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


################################################
#NOTE: When menu becomes visible
################################################
func _on_visibility_changed() -> void:
	if self.visible:
		master_label.grab_focus()
		
		# Get the current audio settings
		master_value.text = str(GameManager.master_volume)
		sound_value.text = str(GameManager.sound_volume)
		music_value.text = str(GameManager.music_volume)


################################################
#NOTE: Input events
################################################
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left") || event.is_action_pressed("ui_left"):
		## Decrease master
		if master_label.has_focus():
			await UiUtility.arrow_buttons_press_animation(master_left_button)
			_update_value(master_value, -1)

		## Decrease sound
		if sound_label.has_focus():
			await UiUtility.arrow_buttons_press_animation(sound_left_button)
			_update_value(sound_value, -1)
		
		## Decrease music
		if music_label.has_focus():
			await UiUtility.arrow_buttons_press_animation(music_left_button)
			_update_value(music_value, -1)
			
	if event.is_action_pressed("move_right") || event.is_action_pressed("ui_right"):
		## Increase master
		if master_label.has_focus():
			await UiUtility.arrow_buttons_press_animation(master_right_button)
			_update_value(master_value, 1)

		## Increase sound
		if sound_label.has_focus():
			await UiUtility.arrow_buttons_press_animation(sound_right_button)
			_update_value(sound_value, 1)
		
		## Increase music
		if music_label.has_focus():
			await UiUtility.arrow_buttons_press_animation(music_right_button)
			_update_value(music_value, 1)


################################################
#NOTE: Only when this menu is visible, show or hide arrow buttons based on the volume values
################################################
func _process(_delta: float) -> void:
	if self.visible:
		_toggle_arrow_button_visibility()

func _toggle_arrow_button_visibility() -> void:
	# Master left button
	if master_value.text.to_int() == GameManager.volume_min:
		master_left_button.visible = false
	else:
		master_left_button.visible = true

	# Master right button
	if master_value.text.to_int() == GameManager.volume_max:
		master_right_button.visible = false
	else:
		master_right_button.visible = true

	# Sound left button
	if sound_value.text.to_int() == GameManager.volume_min:
		sound_left_button.visible = false
	else:
		sound_left_button.visible = true

	# Sound right button
	if sound_value.text.to_int() == GameManager.volume_max:
		sound_right_button.visible = false
	else:
		sound_right_button.visible = true
	
	# Music left button
	if music_value.text.to_int() == GameManager.volume_min:
		music_left_button.visible = false
	else:
		music_left_button.visible = true

	# Sound right button
	if music_value.text.to_int() == GameManager.volume_max:
		music_right_button.visible = false
	else:
		music_right_button.visible = true


################################################
#NOTE: Element focused signal connection
################################################
func _on_element_focused() -> void:
	for element in ui_elements_list:
		if element.has_focus():
			UiUtility.highlight_selected_element(ui_elements_list, element)


################################################
#NOTE: Mouse hovered and focused on element signal connection
################################################
func _on_element_focused_with_mouse(node : Control) -> void:
	if node == master_left_button || node == master_right_button || node == master_value_hbox:
		master_label.grab_focus()
	elif node == sound_left_button || node == sound_right_button || node == sound_value_hbox:
		sound_label.grab_focus()
	elif node == music_left_button || node == music_right_button || node == music_value_hbox:
		music_label.grab_focus()
	else:
		node.grab_focus()


################################################
#NOTE: Button pressed signal connection
################################################
func _on_button_pressed(node: Control) -> void:
	match node:
		back_button:
			await UiUtility.selected_button_element_press_animation(node)
			back_button_pressed.emit()

			# Save audio settings when back button is pressed
			_update_game_manager()
			_save_audio_settings()
		
		master_left_button:
			master_label.grab_focus()
			await UiUtility.arrow_buttons_press_animation(master_left_button)
			_update_value(master_value, -1)
		
		master_right_button:
			master_label.grab_focus()
			await UiUtility.arrow_buttons_press_animation(master_right_button)
			_update_value(master_value, 1)
		
		sound_left_button:
			sound_label.grab_focus()
			await UiUtility.arrow_buttons_press_animation(sound_left_button)
			_update_value(sound_value, -1)

		sound_right_button:
			sound_label.grab_focus()
			await UiUtility.arrow_buttons_press_animation(sound_right_button)
			_update_value(sound_value, 1)
		
		music_left_button:
			music_label.grab_focus()
			await UiUtility.arrow_buttons_press_animation(music_left_button)
			_update_value(music_value, -1)
		
		music_right_button:
			music_label.grab_focus()
			await UiUtility.arrow_buttons_press_animation(music_right_button)
			_update_value(music_value, 1)

		_:
			push_error("Unhandled button pressed: ", node.name)


################################################
#NOTE: Helper func to update volume values
################################################
func _update_value(value_to_change : Label, direction : int):
	var new_value : int = clamp(value_to_change.text.to_int() + (direction * volume_tick), 0, 100)
	value_to_change.text = str(new_value)
	

################################################
#NOTE: Save audio settings to save file
################################################
func _save_audio_settings() -> void:
	GameManager.audio_settings_dictionary["master_volume"] = master_value.text.to_int()
	GameManager.audio_settings_dictionary["sound_volume"] = sound_value.text.to_int()
	GameManager.audio_settings_dictionary["music_volume"] = music_value.text.to_int()
	SaveManager.contents_to_save["settings"]["audio_settings"] = GameManager.audio_settings_dictionary
	SaveManager.save_game()


################################################
#NOTE: Update game manager with current settings
################################################

func _update_game_manager() -> void:
	GameManager.master_volume = master_value.text.to_int()
	GameManager.sound_volume = sound_value.text.to_int()
	GameManager.music_volume = music_value.text.to_int()