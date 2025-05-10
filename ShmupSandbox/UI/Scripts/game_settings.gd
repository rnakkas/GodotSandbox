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

## TODO: 
	# - make the left or right arrow disappear if min or max values are reached - done
	# - make the left or right arrow appear if not at min or max values - done
	# - hook up to save game data
	# - on ready, grab settings from save game data, if not available use default settings
	# - on back button pressed, save settings to save file

func _ready() -> void:
	_create_ui_elements_list()


func _on_visibility_changed() -> void:
	if self.visible:
		lives_label.grab_focus()
		_toggle_arrow_button_visibility()
		


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


## Only when this menu is visible, show or hide arrow buttons based on the lives and credits values
func _process(_delta: float) -> void:
	if self.visible:
		_toggle_arrow_button_visibility()


####

## Signal connections
func _on_element_focused() -> void:
	for element in ui_elements_list:
		if element.has_focus():
			UiUtility.highlight_selected_element(ui_elements_list, element)

func _on_element_focused_with_mouse(node : Control) -> void:
	if node == lives_left_button || node == lives_right_button || node == lives_value_hbox:
		lives_label.grab_focus()
	elif node == credits_left_button || node == credits_right_button || node == credits_value_hbox:
		credits_label.grab_focus()
	else:
		node.grab_focus()

func _on_button_pressed(node: Control) -> void:
	match node:
		back_button:
			await UiUtility.selected_button_element_press_animation(node)
			back_button_pressed.emit()
		
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


####

## Helper funcs
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


func _update_value(value_to_change : Label, allowed_values : Array[int], direction : int):
	var current_value : int = value_to_change.text.to_int()
	var index : int = allowed_values.find(current_value)

	if index == -1:
		push_warning("invalid value, not in allowed_values list: ", str(current_value))
		return
	
	var new_index : int = index + direction
	if new_index >= 0 and new_index < allowed_values.size():
		value_to_change.text = str(allowed_values[new_index])


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
