extends Node

## Colour hex code references
var colour_white : Color = "#f0f6f0"
var colour_black : Color = "#222323"
var colour_transparent : Color = Color(0, 0 , 0, 0)


func highlight_ui_elment(ui_element : Variant) -> void:
	var style : StyleBoxFlat = StyleBoxFlat.new()
	ui_element.add_theme_color_override("font_color", colour_black)
	style.bg_color = colour_white
	ui_element.add_theme_stylebox_override("normal", style)


func remove_highlight_from_ui_element(ui_element : Variant) -> void:
	var style : StyleBoxFlat = StyleBoxFlat.new()
	ui_element.add_theme_color_override("font_color", colour_white)
	style.bg_color = colour_transparent
	ui_element.add_theme_stylebox_override("normal", style)
