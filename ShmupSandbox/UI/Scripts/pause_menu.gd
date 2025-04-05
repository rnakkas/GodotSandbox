class_name pause_menu extends Control

@onready var resume_button: Button = %resume_button
@onready var resume_selector_icon: TextureRect = %resume_selector_icon

@onready var options_button: Button = %options_button
@onready var options_selector_icon: TextureRect = %options_selector_icon

@onready var main_menu_button: Button = %main_menu_button
@onready var main_menu_selector_icon: TextureRect = %main_menu_selector_icon

@onready var quit_button: Button = %quit_button
@onready var quit_selector_icon: TextureRect = %quit_selector_icon

signal resume_button_pressed()
signal options_button_pressed()
signal main_menu_button_pressed()
signal quit_button_pressed()

var selector_icons : Array[TextureRect] = []
var ui_elements_list : Array[Control] = []

func _ready() -> void:
	#_create_icons_list()
	create_ui_elements_list()

## Helper funcs

## ++++ Selector Icons: Keeping this in case I want to use selector icons again ++++
#func _create_icons_list() -> void:
	#selector_icons.append_array(
		#[
			#resume_selector_icon,
			#options_selector_icon,
			#main_menu_selector_icon,
			#quit_selector_icon
		#]
	#)
#
#func _show_button_as_selected(icon: TextureRect) -> void:
	#for i:int in range(selector_icons.size()):
		#if selector_icons[i] == icon:
			#selector_icons[i].visible = true
		#else:
			#selector_icons[i].visible = false


func create_ui_elements_list() -> void:
	ui_elements_list.append_array(
		[
			resume_button,
			options_button,
			main_menu_button,
			quit_button
		]
	)

func _highlight_selected_element(ui_element : Control) -> void:
	for i:int in range(ui_elements_list.size()):
		if ui_elements_list[i] == ui_element:
			UiUtility.highlight_ui_elment(ui_elements_list[i])
		else:
			UiUtility.remove_highlight_from_ui_element(ui_elements_list[i])


####

## Resume button
func _on_resume_button_pressed() -> void:
	resume_button_pressed.emit()

func _on_resume_button_focus_entered() -> void:
	#_show_button_as_selected(resume_selector_icon)
	_highlight_selected_element(resume_button)

func _on_resume_button_mouse_entered() -> void:
	resume_button.grab_focus()


## Options button
func _on_options_button_pressed() -> void:
	options_button_pressed.emit()

func _on_options_button_focus_entered() -> void:
	#_show_button_as_selected(options_selector_icon)
	_highlight_selected_element(options_button)

func _on_options_button_mouse_entered() -> void:
	options_button.grab_focus()


## Main Menu button
func _on_main_menu_button_pressed() -> void:
	main_menu_button_pressed.emit()

func _on_main_menu_button_focus_entered() -> void:
	#_show_button_as_selected(main_menu_selector_icon)
	_highlight_selected_element(main_menu_button)

func _on_main_menu_button_mouse_entered() -> void:
	main_menu_button.grab_focus()


## Quit button
func _on_quit_button_pressed() -> void:
	quit_button_pressed.emit()

func _on_quit_button_focus_entered() -> void:
	#_show_button_as_selected(quit_selector_icon)
	_highlight_selected_element(quit_button)

func _on_quit_button_mouse_entered() -> void:
	quit_button.grab_focus()
