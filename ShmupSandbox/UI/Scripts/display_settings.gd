class_name DisplaySettings extends Control

@onready var mode_label: Label = %mode_label
@onready var mode_value_hbox: HBoxContainer = %HBoxContainer_mode_value
@onready var mode_left_button: TextureButton = %mode_left_button
@onready var mode_value: Label = %mode_value
@onready var mode_right_button: TextureButton = %mode_right_button

@onready var crt_label: Label = %crt_label
@onready var crt_value_hbox: HBoxContainer = %HBoxContainer_crt_value
@onready var crt_left_button: TextureButton = %crt_left_button
@onready var crt_value: Label = %crt_value
@onready var crt_right_button: TextureButton = %crt_right_button

@onready var back_button: Button = %back_button


var ui_elements_list: Array[Control] = []
var allowed_values_mode: Array[String] = ["FULLSCREEN", "WINDOWED"]
var allowed_values_crt: Array[String] = ["OFF", "ON"]

signal back_button_pressed()
signal crt_filter_changed(crt_value: bool)


################################################
#NOTE: Ready
################################################
func _ready() -> void:
    _create_ui_elements_list()

func _create_ui_elements_list() -> void:
    for node: Control in get_tree().get_nodes_in_group(UiUtility.display_settings_ui_nodes):
        ui_elements_list.append(node)
        _connect_to_group_signals(node)
    ui_elements_list.sort() # Sort in alphabetical order


func _connect_to_group_signals(node: Control) -> void:
    if node.has_signal(UiUtility.signal_focus_entered):
        node.focus_entered.connect(self._on_element_focused)
    if node.has_signal(UiUtility.signal_mouse_entered):
        node.mouse_entered.connect(self._on_element_focused_with_mouse.bind(node)) # Use 'bind' to pass source node as property
    if node is Button || node is TextureButton:
        node.pressed.connect(self._on_button_pressed.bind(node))


################################################
#NOTE: When menu becomes visible
################################################
func _on_visibility_changed() -> void:
    if self.visible:
        # Get the current game settings
        if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
            mode_value.text = allowed_values_mode[0]
        elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
            mode_value.text = allowed_values_mode[1]
        
        if GameManager.crt_filter:
            crt_value.text = allowed_values_crt[1]
        elif !GameManager.crt_filter:
            crt_value.text = allowed_values_crt[0]

        mode_label.grab_focus()
        _toggle_arrow_button_visibility()
		

################################################
#NOTE: Input events
################################################
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("move_left") || event.is_action_pressed("ui_left"):
        ## Change window mode
        if mode_label.has_focus():
            await UiUtility.arrow_buttons_press_animation(mode_left_button)
            _update_value(mode_value, allowed_values_mode, -1)
            _change_window_mode()

        ## Toggle crt filter
        if crt_label.has_focus():
            await UiUtility.arrow_buttons_press_animation(crt_left_button)
            _update_value(crt_value, allowed_values_crt, -1)
            _change_crt_filter()
            
    if event.is_action_pressed("move_right") || event.is_action_pressed("ui_right"):
        ## Change window mode
        if mode_label.has_focus():
            await UiUtility.arrow_buttons_press_animation(mode_right_button)
            _update_value(mode_value, allowed_values_mode, 1)
            _change_window_mode()

        ## Toggle crt filter
        if crt_label.has_focus():
            await UiUtility.arrow_buttons_press_animation(crt_right_button)
            _update_value(crt_value, allowed_values_crt, 1)
            _change_crt_filter()


################################################
#NOTE: Only when menu is visible, toggle arrow buttons based on settings values
################################################
func _process(_delta: float) -> void:
    if self.visible:
        _toggle_arrow_button_visibility()

func _toggle_arrow_button_visibility() -> void:
    # Lives left button
    if mode_value.text == allowed_values_mode[0]:
        mode_left_button.visible = false
    else:
        mode_left_button.visible = true

    # Lives right button
    if mode_value.text == allowed_values_mode[allowed_values_mode.size() - 1]:
        mode_right_button.visible = false
    else:
        mode_right_button.visible = true

    # Credits left button
    if crt_value.text == allowed_values_crt[0]:
        crt_left_button.visible = false
    else:
        crt_left_button.visible = true

    # Credits right button
    if crt_value.text == allowed_values_crt[allowed_values_crt.size() - 1]:
        crt_right_button.visible = false
    else:
        crt_right_button.visible = true


################################################
#NOTE: Helper func to change window mode: Windowed or Fullscreen
################################################
func _change_window_mode() -> void:
    if mode_value.text == allowed_values_mode[0]:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    elif mode_value.text == allowed_values_mode[1]:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false) # Allows title bar and border for resize


################################################
#NOTE: Helper func to change crt filter: On or Off
################################################
func _change_crt_filter() -> void:
    if crt_value.text == allowed_values_crt[0]:
        crt_filter_changed.emit(false)
    elif crt_value.text == allowed_values_crt[1]:
        crt_filter_changed.emit(true)


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
func _on_element_focused_with_mouse(node: Control) -> void:
    if node == mode_left_button || node == mode_right_button || node == mode_value_hbox:
        mode_label.grab_focus()
    elif node == crt_left_button || node == crt_right_button || node == crt_value_hbox:
        crt_label.grab_focus()
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
            _save_display_settings()
        
        mode_left_button:
            mode_label.grab_focus()
            await UiUtility.arrow_buttons_press_animation(mode_left_button)
            _update_value(mode_value, allowed_values_mode, -1)
            _change_window_mode()
            
        mode_right_button:
            mode_label.grab_focus()
            await UiUtility.arrow_buttons_press_animation(mode_right_button)
            _update_value(mode_value, allowed_values_mode, 1)
            _change_window_mode()
        
        crt_left_button:
            crt_label.grab_focus()
            await UiUtility.arrow_buttons_press_animation(crt_left_button)
            _update_value(crt_value, allowed_values_crt, -1)
            _change_crt_filter()
        
        crt_right_button:
            crt_label.grab_focus()
            await UiUtility.arrow_buttons_press_animation(crt_right_button)
            _update_value(crt_value, allowed_values_crt, 1)
            _change_crt_filter()

        _:
            push_error("Unhandled button pressed: ", node.name)


################################################
#NOTE: Helper func to update settings values on ui
################################################
func _update_value(value_to_change: Label, allowed_values: Array[String], direction: int):
    var current_value: String = value_to_change.text
    var index: int = allowed_values.find(current_value)

    if index == -1:
        push_warning("invalid value, not in allowed_values list: ", str(current_value))
        return

    var new_index: int = index + direction
    if new_index >= 0 && new_index < allowed_values.size():
        value_to_change.text = str(allowed_values[new_index])


################################################
#NOTE: Save display settings to save file
################################################
func _save_display_settings() -> void:
    GameManager.display_settings_dictionary["window_mode"] = DisplayServer.window_get_mode()

    if crt_value.text == allowed_values_crt[0]:
        GameManager.display_settings_dictionary["crt_filter"] = false
    else:
        GameManager.display_settings_dictionary["crt_filter"] = true
    
    SaveManager.contents_to_save["settings"]["display_settings"] = GameManager.display_settings_dictionary
    SaveManager.save_game()


################################################
#NOTE: Helper func to update game maanger with current settings
################################################
func _update_game_manager() -> void:
    GameManager.window_mode = DisplayServer.window_get_mode()
    
    if crt_value.text == allowed_values_crt[0]:
        GameManager.crt_filter = false
    elif crt_value.text == allowed_values_crt[1]:
        GameManager.crt_filter = true