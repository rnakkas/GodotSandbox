class_name ConfirmDialog extends Control

@onready var yes_button : Button = %yes_button
@onready var no_button : Button = %no_button
@onready var dialog_label_main : Label = %dialog_label

signal yes_button_pressed(dialog_text : String)
signal no_button_pressed()

var ui_elements_list : Array[Control] = []

func _ready() -> void:
	_create_ui_elements_list()

####

## Helper funcs

func _create_ui_elements_list() -> void:
	ui_elements_list.append_array(
		[
			yes_button,
			no_button
		]
	)

####

func _on_yes_button_pressed() -> void:
	await UiUtility.selected_button_element_press_animation(yes_button)
	yes_button_pressed.emit(dialog_label_main.text)


func _on_yes_button_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, yes_button)


func _on_yes_button_mouse_entered() -> void:
	yes_button.grab_focus()


func _on_no_button_pressed() -> void:
	await UiUtility.selected_button_element_press_animation(no_button)
	no_button_pressed.emit()


func _on_no_button_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, no_button)


func _on_no_button_mouse_entered() -> void:
	no_button.grab_focus()


func _on_visibility_changed() -> void:
	if self.visible:
		no_button.grab_focus()
