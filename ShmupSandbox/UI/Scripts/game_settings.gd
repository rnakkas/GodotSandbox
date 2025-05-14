class_name GameSettings extends Control

@onready var lives_value_hbox : HBoxContainer = %HBoxContainer_lives_value
@onready var credits_value_hbox : HBoxContainer = %HBoxContainer_credits_value
@onready var lives_label : Label = %lives_label
@onready var lives_value : Label = %lives_value
@onready var credits_label : Label = %credits_label
@onready var credits_value : Label = %credits_value
@onready var lives_left_button : TextureButton = %lives_left_button
@onready var lives_right_button : TextureButton = %lives_right_button
@onready var credits_left_button : TextureButton = %credits_left_button
@onready var credits_right_button : TextureButton = %credits_right_button
@onready var back_button : Button = %back_button

var ui_elements_list : Array[Control] = []
var allowed_values_lives : Array[int] = [3, 5, 7, 9]
var allowed_values_credits : Array[int] = [1, 3, 5, 7, 9]

signal back_button_pressed()

################################################
#NOTE: Ready
################################################
func _ready() -> void:
	_create_ui_elements_list()

func _create_ui_elements_list() -> void:
	for node : Control in get_tree().get_nodes_in_group(UiUtility.game_settings_ui_nodes):
		ui_elements_list.append(node)
		_connect_to_group_signals(node)
	ui_elements_list.sort() # Sort in alphabetical order


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
		# Get the current game settings
		lives_value.text = str(GameManager._player_max_lives)
		credits_value.text = str(GameManager._player_max_credits)

		lives_label.grab_focus()
		_toggle_arrow_button_visibility()
		

################################################
#NOTE: Input events
################################################
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left") || event.is_action_pressed("ui_left"):
		## Decrease lives
		if lives_label.has_focus():
			await UiUtility.arrow_buttons_press_animation(lives_left_button)
			_update_value(lives_value, allowed_values_lives, -1)

		## Decrease credits
		if credits_label.has_focus():
			await UiUtility.arrow_buttons_press_animation(credits_left_button)
			_update_value(credits_value, allowed_values_credits, -1)
			
	if event.is_action_pressed("move_right") || event.is_action_pressed("ui_right"):
		## Increase lives
		if lives_label.has_focus():
			await UiUtility.arrow_buttons_press_animation(lives_right_button)
			_update_value(lives_value, allowed_values_lives, 1)

		## Increase credits
		if credits_label.has_focus():
			await UiUtility.arrow_buttons_press_animation(credits_right_button)
			_update_value(credits_value, allowed_values_credits, 1)


################################################
#NOTE: Only when menu is visible, toggle arrow buttons based on settings values
################################################
func _process(_delta: float) -> void:
	if self.visible:
		_toggle_arrow_button_visibility()

func _toggle_arrow_button_visibility() -> void:
	# Lives left button
	if lives_value.text.to_int() == allowed_values_lives[0]:
		lives_left_button.visible = false
	else:
		lives_left_button.visible = true

	# Lives right button
	if lives_value.text.to_int() == allowed_values_lives[allowed_values_lives.size()-1]:
		lives_right_button.visible = false
	else:
		lives_right_button.visible = true

	# Credits left button
	if credits_value.text.to_int() == allowed_values_credits[0]:
		credits_left_button.visible = false
	else:
		credits_left_button.visible = true
	
	# Credits right button
	if credits_value.text.to_int() == allowed_values_credits[allowed_values_credits.size()-1]:
		credits_right_button.visible = false
	else: 
		credits_right_button.visible = true


################################################
#NOTE: Element focused signal connection
################################################
func _on_element_focused() -> void:
	for element in ui_elements_list:
		if element.has_focus():
			UiUtility.highlight_selected_element(ui_elements_list, element)


################################################
#NOTE: Mouse hovered signal connection
################################################
func _on_element_focused_with_mouse(node : Control) -> void:
	if node == lives_left_button || node == lives_right_button || node == lives_value_hbox:
		lives_label.grab_focus()
	elif node == credits_left_button || node == credits_right_button || node == credits_value_hbox:
		credits_label.grab_focus()
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

			# Save game settings when back button is pressed
			_update_game_manager()
			_save_game_settings()
		
		lives_left_button:
			lives_label.grab_focus()
			await UiUtility.arrow_buttons_press_animation(lives_left_button)
			_update_value(lives_value, allowed_values_lives, -1)
		
		lives_right_button:
			lives_label.grab_focus()
			await UiUtility.arrow_buttons_press_animation(lives_right_button)
			_update_value(lives_value, allowed_values_lives, 1)
		
		credits_left_button:
			credits_label.grab_focus()
			await UiUtility.arrow_buttons_press_animation(credits_left_button)
			_update_value(credits_value, allowed_values_credits, -1)
		
		credits_right_button:
			credits_label.grab_focus()
			await UiUtility.arrow_buttons_press_animation(credits_right_button)
			_update_value(credits_value, allowed_values_credits, 1)

		_:
			push_error("Unhandled button pressed: ", node.name)


################################################
#NOTE: Helper func to update the settings values on ui 
################################################
func _update_value(value_to_change : Label, allowed_values : Array[int], direction : int):
	var current_value : int = value_to_change.text.to_int()
	var index : int = allowed_values.find(current_value)

	if index == -1:
		push_warning("invalid value, not in allowed_values list: ", str(current_value))
		return
	
	var new_index : int = index + direction
	if new_index >= 0 && new_index < allowed_values.size():
		value_to_change.text = str(allowed_values[new_index])


################################################
#NOTE: Save game settings to save file
################################################
func _save_game_settings() -> void:
	GameManager.game_settings_dictionary["player_max_lives"] = lives_value.text.to_int()
	GameManager.game_settings_dictionary["player_max_credits"] = credits_value.text.to_int()
	SaveManager.contents_to_save["settings"]["game_settings"] = GameManager.game_settings_dictionary
	SaveManager.save_game()


################################################
#NOTE: Helper func to update game manager with current settings
################################################
func _update_game_manager() -> void:
	GameManager._player_max_lives = lives_value.text.to_int()
	GameManager._player_max_credits = credits_value.text.to_int()