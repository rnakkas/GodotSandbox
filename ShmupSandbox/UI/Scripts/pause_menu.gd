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

func _ready() -> void:
	_create_icons_list()

## Helper funcs
func _create_icons_list() -> void:
	selector_icons.append_array(
		[
			resume_selector_icon,
			options_selector_icon,
			main_menu_selector_icon,
			quit_selector_icon
		]
	)

func _on_resume_button_pressed() -> void:
	print("resume game")
	resume_button_pressed.emit()


func _on_options_button_pressed() -> void:
	options_button_pressed.emit()


func _on_main_menu_button_pressed() -> void:
	main_menu_button_pressed.emit()


func _on_quit_button_pressed() -> void:
	quit_button_pressed.emit()
