class_name NameEntryDialog extends Control

@onready var score_label : Label = %score_label

var ui_elements_list : Array[Control] = []

## TODO: Name entry dialog WIP

func _ready() -> void:
	_initialize_letters_list()
	print("list of letters labels: ", ui_elements_list, "\n")

	ui_elements_list[0].grab_focus()


func _initialize_letters_list() -> void:
	for node : Node in get_tree().get_nodes_in_group("name_entry_dialog_letters"):
		if node is Label:
			ui_elements_list.append(node)
	ui_elements_list.sort()


func _on_letter_1_focus_entered() -> void:
	print("letter 1 focused")
	UiUtility.highlight_selected_element(ui_elements_list, ui_elements_list[0])
