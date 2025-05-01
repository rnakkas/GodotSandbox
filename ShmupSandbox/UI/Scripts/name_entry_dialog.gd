class_name NameEntryDialog extends Control

@onready var score_label : Label = %score_label
@onready var blink_timer : Timer = $blink_timer

var letter_labels_list : Array[Label] = []
var letter_containers_list : Array[Control] = []
const blink_time : float = 0.4
# const allowed_chars : Array[String] = [
# 	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L",
# 	"M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X",
# 	"Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
# 	"!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "_",
# 	"+", "=", "/", "<", ">", "?", ".", ","
# ]

## FIXME: For testing only, remove
const allowed_chars : Array[String] = [
	"A", "B", "C", "D", "E", "F"
]



## TODO: Name entry dialog WIP
## NEXT:
	# Being able to confirm on selecting a letter for the name
	# Once a selection on a letter is made, move focus to the next letter
	# Once all letters have been selected, send signal to move player to game over screen
	# Also add a timer to automatically set name and move to game over screen if player idles too long on this dialog
	# Grab focus on first letter from left when dialog becomes visible, i.e. connect to visibility_changed signal

func _ready() -> void:
	_initialize_letters_list()
	_initialize_letter_containers_list()
	_set_blink_timer_properties()

	## FIXME: For testing only, will remove
	letter_containers_list[0]. grab_focus()


## Get the list of letters and connect to their signals
func _initialize_letters_list() -> void:
	for node : Node in get_tree().get_nodes_in_group("name_entry_dialog_letters"):
		if node is Label:
			letter_labels_list.append(node)
			_connect_to_group_signals(node)
	letter_labels_list.sort()

## Get the list of letter containers and connect to their signals
func _initialize_letter_containers_list() -> void:
	for node : Node in get_tree().get_nodes_in_group("name_entry_dialog_letter_containers"):
		if node is Control:
			letter_containers_list.append(node)
			_connect_to_group_signals(node)
	letter_containers_list.sort()

## Helper function for connecting to group signals for the letters and containers
func _connect_to_group_signals(node : Control) -> void:
	if node.has_signal("focus_entered"):
		node.focus_entered.connect(_on_focus_entered)


####

## Blinking timer properties
func _set_blink_timer_properties() -> void:
	blink_timer.wait_time = blink_time
	blink_timer.one_shot = false


####

## Selecting letters for name entry
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up") || event.is_action_pressed("ui_up"):
		_scroll_up()
	elif event.is_action_pressed("move_down") || event.is_action_pressed("ui_down"):
		_scroll_down()
	elif event.is_action_pressed("shoot") || event.is_action_pressed("ui_accept"):
		_accept_letter()

## When user scrolls up
func _scroll_up() -> void:
	for element : int in range(letter_containers_list.size()):
		if letter_containers_list[element].has_focus():
			for character : int in range(allowed_chars.size()):
				if letter_labels_list[element].text == allowed_chars[character]:
					# Reset char index back to 0 by getting modulus of character+1 vs size of chars array
					# This loops array back to start
					character = (character + 1)%allowed_chars.size()
					letter_labels_list[element].text = allowed_chars[character]
					break

## When user scrolls down
func _scroll_down() -> void:
	for element : int in range(letter_containers_list.size()):
		if letter_containers_list[element].has_focus():
			for character : int in range(allowed_chars.size()):
				if letter_labels_list[element].text == allowed_chars[character]:
					# Reset char index back to 0 by getting modulus of character-1 vs size of chars array
					# This loops array back to start
					character = (character - 1)%allowed_chars.size()
					letter_labels_list[element].text = allowed_chars[character]
					break

## When user accepts selected letter
func _accept_letter() -> void:
	for element : int in range(letter_containers_list.size()):
		if letter_containers_list[element].has_focus(): 
			if element < letter_containers_list.size()-1:
				letter_containers_list[element].get_child(0).visible = true
				letter_containers_list[element+1].grab_focus()
				break
			elif element == letter_containers_list.size()-1:
				letter_containers_list[element].release_focus()
				print("confirmed all letters")



####

## Signals connections

func _on_focus_entered() -> void:
	for element : int in range(letter_containers_list.size()):
		if letter_containers_list[element].has_focus():
			letter_containers_list[element].modulate = UiUtility.color_yellow
			blink_timer.start()	



func _on_blink_timer_timeout() -> void:
	_blink_current_letter()

## Helper function for blinking the currently highlighted letter label
func _blink_current_letter() -> void:
	for element : int in range(letter_containers_list.size()):
		if letter_containers_list[element].has_focus():
			letter_containers_list[element].get_child(0).visible = !letter_containers_list[element].get_child(0).visible
