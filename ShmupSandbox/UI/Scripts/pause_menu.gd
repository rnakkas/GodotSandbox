class_name PauseMenu extends Control

@onready var resume_button: Button = %resume_button
@onready var options_button: Button = %options_button
@onready var main_menu_button: Button = %main_menu_button
@onready var quit_button: Button = %quit_button

signal resume_button_pressed()
signal options_button_pressed()
signal main_menu_button_pressed()
signal quit_button_pressed()

var selector_icons: Array[TextureRect] = []
var ui_elements_list: Array[Control] = []

## TODO: Fix the issue with accept button being held on menu item, make it the same as main menu

################################################
#NOTE: Ready
################################################
func _ready() -> void:
	_create_ui_elements_list()

func _create_ui_elements_list() -> void:
	for node: Button in get_tree().get_nodes_in_group(UiUtility.pause_menu_ui_nodes):
		ui_elements_list.append(node)


################################################
#NOTE: When pause menu becomes visible
################################################
func _on_visibility_changed() -> void:
	if self.visible:
		resume_button.grab_focus()


################################################
#NOTE: Signal connection: Resume button
################################################
func _on_resume_button_pressed() -> void:
	await UiUtility.selected_button_element_press_animation(resume_button)
	resume_button_pressed.emit()

func _on_resume_button_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, resume_button)

func _on_resume_button_mouse_entered() -> void:
	resume_button.grab_focus()


################################################
#NOTE: Signal connection: Options button
################################################
func _on_options_button_pressed() -> void:
	await UiUtility.selected_button_element_press_animation(options_button)
	options_button_pressed.emit()

func _on_options_button_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, options_button)

func _on_options_button_mouse_entered() -> void:
	options_button.grab_focus()


################################################
#NOTE: Signal connection: Main Menu button
################################################
func _on_main_menu_button_pressed() -> void:
	await UiUtility.selected_button_element_press_animation(main_menu_button)
	main_menu_button_pressed.emit()

func _on_main_menu_button_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, main_menu_button)

func _on_main_menu_button_mouse_entered() -> void:
	main_menu_button.grab_focus()


################################################
#NOTE: Signal connection: Quit button
################################################
func _on_quit_button_pressed() -> void:
	await UiUtility.selected_button_element_press_animation(quit_button)
	quit_button_pressed.emit()

func _on_quit_button_focus_entered() -> void:
	UiUtility.highlight_selected_element(ui_elements_list, quit_button)

func _on_quit_button_mouse_entered() -> void:
	quit_button.grab_focus()
