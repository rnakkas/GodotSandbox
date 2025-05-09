class_name GameSettings extends Control

@onready var lives_label : Label = %lives_label
@onready var credits_label : Label = %credits_label
@onready var lives_left_button : TextureButton = %lives_left_button
@onready var lives_right_button : TextureButton = %lives_right_button
@onready var credits_left_button : TextureButton = %credits_left_button
@onready var credits_right_button : TextureButton = %credits_right_button
@onready var back_button : Button = %back_button

var ui_elements_list : Array[Control] = []

signal back_button_pressed()


func _ready() -> void:
	_create_ui_elements_list()


func _on_visibility_changed() -> void:
	if self.visible:
		lives_label.grab_focus()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left") || event.is_action_pressed("ui_left"):
		if lives_label.has_focus():
			print("decrease lives")
			_toggle_arrow_buttons(lives_left_button)

		if credits_label.has_focus():
			print("decrease credits")
			_toggle_arrow_buttons(credits_left_button)
			
	if event.is_action_pressed("move_right") || event.is_action_pressed("ui_right"):
		if lives_label.has_focus():
			print("increase lives")
			_toggle_arrow_buttons(lives_right_button)

		if credits_label.has_focus():
			print("increase credits")
			_toggle_arrow_buttons(credits_right_button)

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
	if node is Button:
		node.pressed.connect(_on_button_pressed.bind(node))

func _on_element_focused() -> void:
	for element in ui_elements_list:
		if element.has_focus():
			UiUtility.highlight_selected_element(ui_elements_list, element)

func _on_element_focused_with_mouse(node : Control) -> void:
	node.grab_focus()
	if node == lives_left_button || node == lives_right_button:
		UiUtility.highlight_selected_element(ui_elements_list, lives_label)

func _on_button_pressed(node: Button) -> void:
	await UiUtility.selected_button_element_press_animation(node)

	match node:
		back_button:
			back_button_pressed.emit()
		lives_left_button:
			_toggle_arrow_buttons(lives_left_button)
			print("clicked")
		_:
			push_error("Unhandled button pressed: ", node.name)

func _toggle_arrow_buttons(button : TextureButton) -> void:
	button.toggle_mode = true 
	button.button_pressed = true
	await get_tree().create_timer(0.2).timeout
	button.toggle_mode = false 
