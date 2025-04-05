class_name main_menu extends Control

@onready var play_button: Button = %play_button
#@onready var play_selector_icon : TextureRect = %play_selector_icon

@onready var options_button: Button = %options_button
#@onready var options_selector_icon: TextureRect = %options_selector_icon

@onready var hi_scores_button: Button = %hi_scores_button
#@onready var hi_scores_selector_icon : TextureRect = %hi_scores_selector_icon

@onready var quit_button: Button = %quit_button
#@onready var quit_selector_icon : TextureRect = %quit_selector_icon

signal play_button_pressed()
signal options_button_pressed()
signal hi_scores_button_pressed()
signal quit_button_pressed()

#var selector_icons : Array[TextureRect] = []
var ui_elements_list : Array[Control] = []

func _ready() -> void:
	#_create_icons_list()
	create_ui_elements_list()
	
	if self.visible:
		play_button.call_deferred("grab_focus")

####

## Helper funcs

## ++++ Selector Icons: Keeping this in case I want to use selector icons again ++++
#func _create_icons_list() -> void:
	#selector_icons.append_array(
		#[
			#play_selector_icon,
			#options_selector_icon,
			#hi_scores_selector_icon,
			#quit_selector_icon
		#]
	#)
#func _show_button_as_selected(icon: TextureRect) -> void:
	#for i:int in range(selector_icons.size()):
		#if selector_icons[i] == icon:
			#selector_icons[i].visible = true
		#else:
			#selector_icons[i].visible = false


func create_ui_elements_list() -> void:
	ui_elements_list.append_array(
		[
			play_button,
			options_button,
			hi_scores_button,
			quit_button
		]
	)

####

## Play button
func _on_play_button_pressed() -> void:
	play_button_pressed.emit()
	
func _on_play_button_focus_entered() -> void:
	#_show_button_as_selected(play_selector_icon)
	UiUtility.highlight_selected_element(ui_elements_list, play_button)

func _on_play_button_mouse_entered() -> void:
	play_button.grab_focus()


## Options button
func _on_options_button_pressed() -> void:
	options_button_pressed.emit()

func _on_options_button_focus_entered() -> void:
	#_show_button_as_selected(options_selector_icon)
	UiUtility.highlight_selected_element(ui_elements_list, options_button)

func _on_options_button_mouse_entered() -> void:
	options_button.grab_focus()


## Hi scores button
func _on_hi_scores_button_pressed() -> void:
	hi_scores_button_pressed.emit()

func _on_hi_scores_button_focus_entered() -> void:
	#_show_button_as_selected(hi_scores_selector_icon)
	UiUtility.highlight_selected_element(ui_elements_list, hi_scores_button)

func _on_hi_scores_button_mouse_entered() -> void:
	hi_scores_button.grab_focus()


## Quit button
func _on_quit_button_pressed() -> void:
	quit_button_pressed.emit()

func _on_quit_button_focus_entered() -> void:
	#_show_button_as_selected(quit_selector_icon)
	UiUtility.highlight_selected_element(ui_elements_list, quit_button)

func _on_quit_button_mouse_entered() -> void:
	quit_button.grab_focus()
