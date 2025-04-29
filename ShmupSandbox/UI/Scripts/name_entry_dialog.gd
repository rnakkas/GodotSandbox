class_name NameEntryDialog extends Control

@onready var score_label : Label = %score_label
@onready var blink_timer : Timer = $blink_timer

var ui_elements_list : Array[Control] = []
const blink_time : float = 0.4

## TODO: Name entry dialog WIP
## Try:
	# Getting the container to be the highlighted element
	# Then just toggling visibility of the letter label?

func _ready() -> void:
	_initialize_letters_list()
	_set_blink_timer_properties()

	## FIXME: Just using this for testing only, will remove
	ui_elements_list[2]. grab_focus()


## Get the list of letters and connect to their signals
func _initialize_letters_list() -> void:
	for node : Node in get_tree().get_nodes_in_group("name_entry_dialog_letters"):
		if node is Label:
			ui_elements_list.append(node)
			_connect_to_group_signals(node)
	ui_elements_list.sort()

## Helper function for connecting to group signals for the letters
func _connect_to_group_signals(node : Label) -> void:
	if node.has_signal("focus_entered"):
		node.focus_entered.connect(_on_letter_label_focus_entered)


## Blinking timer properties
func _set_blink_timer_properties() -> void:
	blink_timer.wait_time = blink_time
	blink_timer.one_shot = false


## Helper function for blinking the currently highlighted letter label
func _blink_current_letter() -> void:
	for element : int in range(ui_elements_list.size()):
		if ui_elements_list[element].has_focus():
			ui_elements_list[element].visible = !ui_elements_list[element].visible
		elif !ui_elements_list[element].visible:
			ui_elements_list[element].visible = !ui_elements_list[element].visible
			ui_elements_list[element].grab_focus()

####

## Signals connections

func _on_letter_label_focus_entered() -> void:
	for element : int in range(ui_elements_list.size()):
		if ui_elements_list[element].has_focus():
			UiUtility.highlight_selected_element(ui_elements_list, ui_elements_list[element])
			blink_timer.start()


func _on_blink_timer_timeout() -> void:
	_blink_current_letter()
