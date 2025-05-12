extends Node

## UI dialog box strings
var dialog_return_to_main_menu = "Return to Main Menu?"
var dialog_quit = "Exit the game?"

## Colour and hex code references
var color_white : Color = "#f0f6f0"
var color_black : Color = "#222323"
var color_yellow : Color = "#ffa31f"
var color_red : Color = "#e24b13"
var color_transparent : Color = Color(0, 0 , 0, 0)

## UI group names
var options_ui_nodes : String = "options_ui_nodes"
var game_settings_ui_nodes : String = "game_settings_ui_nodes"

## Control node signal names
var signal_focus_entered : String = "focus_entered"
var signal_mouse_entered : String = "mouse_entered"


func highlight_selected_element(ui_elements_list : Array[Control], selected_element : Control) -> void:
	for element:int in range(ui_elements_list.size()):
		if ui_elements_list[element] == selected_element:
			_highlight_ui_elment(ui_elements_list[element])
		else:
			_remove_highlight_from_ui_element(ui_elements_list[element])


func selected_button_element_press_animation(selected_element : Button) -> void:
	_remove_highlight_from_ui_element(selected_element)
	selected_element.focus_mode = Control.FOCUS_NONE
	await get_tree().create_timer(0.2).timeout
	selected_element.focus_mode = Control.FOCUS_ALL


func _highlight_ui_elment(ui_element : Control) -> void:
	var style : StyleBoxFlat = StyleBoxFlat.new()
	ui_element.add_theme_color_override("font_color", color_black)
	style.bg_color = color_yellow
	
	ui_element.add_theme_stylebox_override("normal", style)
	ui_element.add_theme_stylebox_override("focus", style)
	ui_element.add_theme_stylebox_override("hover", style)
	ui_element.add_theme_stylebox_override("normal", style)
	
	ui_element.add_theme_color_override("font_hover_color", color_black)
	ui_element.add_theme_color_override("font_focus_color", color_black)
	ui_element.add_theme_color_override("font_pressed_color", color_white)


func _remove_highlight_from_ui_element(ui_element : Control) -> void:
	var style : StyleBoxFlat = StyleBoxFlat.new()
	ui_element.add_theme_color_override("font_color", color_white)
	style.bg_color = color_transparent
	ui_element.add_theme_stylebox_override("normal", style)


func arrow_buttons_press_animation(button : TextureButton) -> void:
	button.toggle_mode = true 
	button.button_pressed = true
	await get_tree().create_timer(0.13).timeout
	button.toggle_mode = false 
	button.button_pressed = false