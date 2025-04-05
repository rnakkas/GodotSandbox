extends Node

## Colour and hex code references
var color_white : Color = "#f0f6f0"
var color_black : Color = "#222323"
var color_transparent : Color = Color(0, 0 , 0, 0)


func highlight_ui_elment(ui_element : Control) -> void:
	var style : StyleBoxFlat = StyleBoxFlat.new()
	ui_element.add_theme_color_override("font_color", color_black)
	style.bg_color = color_white
	
	match ui_element.get_class():
		"Label":
			ui_element.add_theme_stylebox_override("normal", style)
		"Button":
			ui_element.add_theme_stylebox_override("focus", style)
			ui_element.add_theme_stylebox_override("hover", style)
			ui_element.add_theme_color_override("font_hover_color", color_black)
			ui_element.add_theme_color_override("font_focus_color", color_black)
			ui_element.add_theme_color_override("font_pressed_color", color_white)


func remove_highlight_from_ui_element(ui_element : Variant) -> void:
	var style : StyleBoxFlat = StyleBoxFlat.new()
	ui_element.add_theme_color_override("font_color", color_white)
	style.bg_color = color_transparent
	ui_element.add_theme_stylebox_override("normal", style)
