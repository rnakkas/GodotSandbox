class_name NameEntryDialog extends Control

@onready var score_label : Label = %score_label
@onready var ok_button : Button = %ok_button
@onready var blink_timer : Timer = $blink_timer
@onready var idle_timer : Timer = $idle_timer

var letter_labels_list : Array[Label] = []
var letter_containers_list : Array[Control] = []

const blink_time : float = 0.4
@export var idle_time : float = 30.0

const allowed_chars : Array[String] = [
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L",
	"M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X",
	"Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
	"!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "_",
	"+", "=", "/", "<", ">", "?", ".", ","
]

signal ok_button_pressed()


################################################
#NOTE: Ready
################################################
func _ready() -> void:
	_initialize_letters_list()
	_initialize_letter_containers_list()
	_set_blink_timer_properties()
	_set_idle_timer_properties()


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


## Blinking timer properties
func _set_blink_timer_properties() -> void:
	blink_timer.wait_time = blink_time
	blink_timer.one_shot = false


## Idle timer properties
func _set_idle_timer_properties() -> void:
	idle_timer.wait_time = idle_time
	idle_timer.one_shot = true



################################################
#NOTE: When the name entry dialog becomes visible
################################################
## When this dialog becomes visible
func _on_visibility_changed() -> void:
	if self.visible:
		score_label.text = str(GameManager.player_score)
		_reset_name_entry_letters()
		idle_timer.start()

## To reset the letters back to AAA in the name entry, and ok to be made invisible
func _reset_name_entry_letters() -> void:
	ok_button.visible = !ok_button.visible
	letter_containers_list[0].grab_focus()

	for letter : int in range(letter_labels_list.size()):
		letter_labels_list[letter].text = allowed_chars[0]


################################################
#NOTE: Input events
################################################
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
			letter_containers_list[element].get_child(0).visible = true
			if element < letter_containers_list.size()-1:
				letter_containers_list[element+1].grab_focus()
				break
			elif element == letter_containers_list.size()-1:
				letter_containers_list[element].release_focus()
				blink_timer.stop()
				await get_tree().create_timer(0.3).timeout
				ok_button.visible = true
				ok_button.grab_focus()
				print("confirmed all letters")


################################################
#NOTE: Signal connections
################################################
## Focus entered for letter containers
func _on_focus_entered() -> void:
	for element : int in range(letter_containers_list.size()):
		if letter_containers_list[element].has_focus():
			letter_containers_list[element].modulate = UiUtility.color_yellow
			blink_timer.start()	


## Blinking timer
func _on_blink_timer_timeout() -> void:
	_blink_current_letter()

## Helper function for blinking the currently highlighted letter label
func _blink_current_letter() -> void:
	for element : int in range(letter_containers_list.size()):
		if letter_containers_list[element].has_focus():
			letter_containers_list[element].get_child(0).visible = !letter_containers_list[element].get_child(0).visible


## OK button behaviour
func _on_ok_button_focus_entered() -> void:
	UiUtility.highlight_selected_element([ok_button], ok_button)

func _on_ok_button_pressed() -> void:
	await UiUtility.selected_button_element_press_animation(ok_button)
	var player_name_string : String = ""
	for letter : int in range(letter_labels_list.size()):
		player_name_string += letter_labels_list[letter].text
	
	ok_button_pressed.emit()
	SignalsBus.player_hi_score_name_entered_event(player_name_string)


## If player is idle for too long, name entry is chosen for them
func _on_idle_timer_timeout() -> void:
	_name_entry_when_idle()

func _name_entry_when_idle() -> void:
	var player_name_string : String = ""
	for letter : int in range(letter_labels_list.size()):
		player_name_string += letter_labels_list[letter].text
		letter_labels_list[letter].visible = true
	
	# Highlight the letters as if a selection has been made
	for container : int in range(letter_containers_list.size()):
		letter_containers_list[container].modulate = UiUtility.color_yellow

	ok_button.visible = !ok_button.visible
	ok_button.grab_focus()

	# Just to be able to see the ok being highlighted for a split second to indicate a choice was made
	await get_tree().create_timer(0.25).timeout
	await UiUtility.selected_button_element_press_animation(ok_button)

	ok_button_pressed.emit()
	SignalsBus.player_hi_score_name_entered_event(player_name_string)
