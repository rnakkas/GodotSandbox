class_name OptionsMenu extends Control

signal back_button_pressed()
signal game_settings_button_pressed()
signal display_settings_button_pressed()
signal audio_settings_button_pressed()

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
	ui_elements_list.sort() # Sort in alphabetical order

func _connect_to_group_signals(node : Control) -> void:
	if node.has_signal("focus_entered"):
		node.focus_entered.connect(_on_element_focused)
	if node.has_signal("mouse_entered"):
		# Use 'bind' to know which node emitted the mouse_entered signal
		node.mouse_entered.connect(_on_element_focused_with_mouse.bind(node)) 
	if node is Button:
		node.pressed.connect(_on_button_pressed.bind(node))

####
## Signal connections

func _on_element_focused() -> void:
	_check_for_focused_element()

func _check_for_focused_element() -> void:
	for element : int in range(ui_elements_list.size()):
		if ui_elements_list[element].has_focus():
			UiUtility.highlight_selected_element(ui_elements_list, ui_elements_list[element])


func _on_element_focused_with_mouse(node : Control) -> void:
	node.grab_focus()


func _on_button_pressed(node : Button) -> void:
	await UiUtility.selected_button_element_press_animation(node)

	match node.name:
		"01_game_settings_button":
			game_settings_button_pressed.emit()
		"02_display_settings_button":
			display_settings_button_pressed.emit()
		"03_audio_settings_button":
			audio_settings_button_pressed.emit()
		"04_back_button":
			back_button_pressed.emit()
		

func _on_visibility_changed() -> void:
	if self.visible:
		ui_elements_list[0].grab_focus()
