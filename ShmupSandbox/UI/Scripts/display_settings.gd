class_name DisplaySettings extends Control

@onready var mode_label : Label = %mode_label
@onready var mode_value_hbox : HBoxContainer = %HBoxContainer_mode_value
@onready var mode_left_button : TextureButton = %mode_left_button
@onready var mode_value : Label = %mode_value
@onready var mode_right_button : TextureButton = %mode_right_button

@onready var crt_label : Label = %crt_label
@onready var crt_value_hbox : HBoxContainer = %HBoxContainer_crt_value
@onready var crt_left_button : TextureButton = %crt_left_button
@onready var crt_value : Label = %crt_value
@onready var crt_right_button : TextureButton = %crt_right_button

@onready var back_button : Button = %back_button


var ui_elements_list : Array[Control] = []
var allowed_values_mode : Array[String] = ["Fullscreen", "Windowed"]
var allowed_values_crt : Array[String] = ["Off", "On"]

signal back_button_pressed()

func _ready() -> void:
    _create_ui_elements_list()


## TODO: 
    ## - When window mode is changed, immediately change the window mode to be as selected, i.e. fullscreen or windowed
    ## - create the crt filter, see godotshaders.com
    ## - When crt filter is turned on or off, immediate turn crt filter shader on or off
    ## - When back button is pressed, save these display settings to save file
    ## - Rework the save file contents_to_save so that it doesn't need high scores, game settings etc to save, only
    ##       the changed data is appended to the save file - done

####
## FOR SAVE DATA
func _create_game_settings_save_data() -> void:
    GameManager.display_settings_dictionary["window_mode"] = mode_value.text
    GameManager.display_settings_dictionary["crt_filter"] = crt_value.text
####


func _on_visibility_changed() -> void:
    if self.visible:
        # Get the current game settings
        if GameManager.window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
            mode_value.text = allowed_values_mode[0]
        elif GameManager.window_mode == DisplayServer.WINDOW_MODE_WINDOWED:
            mode_value.text = allowed_values_mode[1]
        
        if GameManager.crt_filter:
            crt_value.text = allowed_values_crt[1]
        elif !GameManager.crt_filter:
            crt_value.text = allowed_values_crt[0]

        mode_label.grab_focus()
        _toggle_arrow_button_visibility()
		

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("move_left") || event.is_action_pressed("ui_left"):
        ## Decrease lives
        if mode_label.has_focus():
            await UiUtility.arrow_buttons_press_animation(mode_left_button)
            _update_value(mode_value, allowed_values_mode, -1)

        ## Decrease credits
        if crt_label.has_focus():
            await UiUtility.arrow_buttons_press_animation(crt_left_button)
            _update_value(crt_value, allowed_values_crt, -1)
            
    if event.is_action_pressed("move_right") || event.is_action_pressed("ui_right"):
        ## Increase lives
        if mode_label.has_focus():
            await UiUtility.arrow_buttons_press_animation(mode_right_button)
            _update_value(mode_value, allowed_values_mode, 1)

        ## Increase credits
        if crt_label.has_focus():
            await UiUtility.arrow_buttons_press_animation(crt_right_button)
            _update_value(crt_value, allowed_values_crt, 1)


## Only when this menu is visible, show or hide arrow buttons based on the lives and credits values
func _process(_delta: float) -> void:
    if self.visible:
        _toggle_arrow_button_visibility()


####


func _create_ui_elements_list() -> void:
    for node : Control in get_tree().get_nodes_in_group(UiUtility.display_settings_ui_nodes):
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


## Signal connections
func _on_element_focused() -> void:
    for element in ui_elements_list:
        if element.has_focus():
            UiUtility.highlight_selected_element(ui_elements_list, element)


func _on_element_focused_with_mouse(node : Control) -> void:
    if node == mode_left_button || node == mode_right_button || node == mode_value_hbox:
        mode_label.grab_focus()
    elif node == crt_left_button || node == crt_right_button || node == crt_value_hbox:
        crt_label.grab_focus()
    else:
        node.grab_focus()

func _on_button_pressed(node: Control) -> void:
    match node:
        back_button:
            await UiUtility.selected_button_element_press_animation(node)
            back_button_pressed.emit()

            # # Save game settings when back button is pressed
            # _create_game_settings_save_data()
            # SignalsBus.game_settings_updated_event()
        
        mode_left_button:
            mode_label.grab_focus()
            await UiUtility.arrow_buttons_press_animation(mode_left_button)
            _update_value(mode_value, allowed_values_mode, -1)
        
        mode_right_button:
            mode_label.grab_focus()
            await UiUtility.arrow_buttons_press_animation(mode_right_button)
            _update_value(mode_value, allowed_values_mode, 1)
        
        crt_left_button:
            crt_label.grab_focus()
            await UiUtility.arrow_buttons_press_animation(crt_left_button)
            _update_value(crt_value, allowed_values_crt, -1)
        
        crt_right_button:
            crt_label.grab_focus()
            await UiUtility.arrow_buttons_press_animation(crt_right_button)
            _update_value(crt_value, allowed_values_crt, 1)

        _:
            push_error("Unhandled button pressed: ", node.name)


func _update_value(value_to_change : Label, allowed_values : Array[String], direction : int):
    var current_value : String = value_to_change.text
    var index : int = allowed_values.find(current_value)

    if index == -1:
        push_warning("invalid value, not in allowed_values list: ", str(current_value))
        return

    var new_index : int = index + direction
    if new_index >= 0 && new_index < allowed_values.size():
        value_to_change.text = str(allowed_values[new_index])


func _toggle_arrow_button_visibility() -> void:
    # Lives left button
    if mode_value.text == allowed_values_mode[0]:
        mode_left_button.visible = false
    else:
        mode_left_button.visible = true

    # Lives right button
    if mode_value.text == allowed_values_mode[allowed_values_mode.size()-1]:
        mode_right_button.visible = false
    else:
        mode_right_button.visible = true

    # Credits left button
    if crt_value.text == allowed_values_crt[0]:
        crt_left_button.visible = false
    else:
        crt_left_button.visible = true

    # Credits right button
    if crt_value.text == allowed_values_crt[allowed_values_crt.size()-1]:
        crt_right_button.visible = false
    else: 
        crt_right_button.visible = true
