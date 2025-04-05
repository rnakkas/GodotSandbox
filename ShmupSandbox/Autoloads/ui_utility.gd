extends Node

## Colour and hex code references
var color_white : Color = "#f0f6f0"
var color_black : Color = "#222323"
var color_yellow : Color = "#ffa31f"
var color_transparent : Color = Color(0, 0 , 0, 0)


func highlight_selected_element(ui_elements_list : Array[Control], selected_element : Control) -> void:
	for element:int in range(ui_elements_list.size()):
		if ui_elements_list[element] == selected_element:
			_highlight_ui_elment(ui_elements_list[element])
		else:
			_remove_highlight_from_ui_element(ui_elements_list[element])


func _highlight_ui_elment(ui_element : Control) -> void:
	var style : StyleBoxFlat = StyleBoxFlat.new()
	ui_element.add_theme_color_override("font_color", color_black)
	style.bg_color = color_white
	
	ui_element.add_theme_stylebox_override("normal", style)
	ui_element.add_theme_stylebox_override("focus", style)
	ui_element.add_theme_stylebox_override("hover", style)
	ui_element.add_theme_stylebox_override("normal", style)
	
	ui_element.add_theme_color_override("font_hover_color", color_black)
	ui_element.add_theme_color_override("font_focus_color", color_black)
	ui_element.add_theme_color_override("font_pressed_color", color_white)


func _remove_highlight_from_ui_element(ui_element : Variant) -> void:
	var style : StyleBoxFlat = StyleBoxFlat.new()
	ui_element.add_theme_color_override("font_color", color_white)
	style.bg_color = color_transparent
	ui_element.add_theme_stylebox_override("normal", style)
