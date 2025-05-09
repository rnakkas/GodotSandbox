class_name GameSettings extends Control

@onready var lives_label : Label = %lives_label
@onready var back_button : Button = %back_button

var ui_elements_list : Array[Control] = []

signal back_button_pressed()


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
    if node is Button:
        node.pressed.connect(_on_button_pressed.bind(node))

func _on_element_focused() -> void:
    for element : int in range(ui_elements_list.size()):
        if ui_elements_list[element].has_focus():
            UiUtility.highlight_selected_element(ui_elements_list, ui_elements_list[element])

func _on_element_focused_with_mouse(node : Control) -> void:
    node.grab_focus()

func _on_button_pressed(node: Button) -> void:
    await UiUtility.selected_button_element_press_animation(node)

    match node:
        back_button:
            back_button_pressed.emit()




func _on_visibility_changed() -> void:
    if self.visible:
        lives_label.grab_focus()
