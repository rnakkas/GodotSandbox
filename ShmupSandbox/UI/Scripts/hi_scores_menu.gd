class_name HiScoresMenu extends Control

@onready var back_button : Button = %back_button

var player_hi_scores_list : Array[int] = []
var score_label_list : Array[Label] = []
var name_label_list : Array[Label] = []


signal back_button_pressed()

func _ready() -> void:
	populate_high_scores_screen()


## Helper funcs
func populate_high_scores_screen() -> void:
	# Step 1: Initialize the score and name label lists
	_initialize_label_lists()

	# Step 2: Sort list of high scores
	GameManager.sort_high_scores()

	# Step 3: Resize the label lists to match the size of high scores list
	_resize_label_lists()

	# Step 4: Sort the label lists
	_sort_label_lists()

	# Step 5: Update the high score UI
	_update_high_score_ui()


## Private funcs
func _initialize_label_lists() -> void:
	## Get all the score labels, score labels are in the named group
	for node : Node in get_tree().get_nodes_in_group("hi_score_score_label"):
		if node is Label:
			score_label_list.append(node)
	
	## Get the name labels from the group
	for node : Node in get_tree().get_nodes_in_group("hi_score_name_label"):
		if node is Label:
			name_label_list.append(node)


func _resize_label_lists() -> void:
	## Ensure size is same as list of high scores
	score_label_list.resize(GameManager.player_hi_scores_dictionaries.size())
	name_label_list.resize(GameManager.player_hi_scores_dictionaries.size())


func _sort_label_lists() -> void:
	## Sort alphabetically, i.e. 1st, 2nd, 3rd etc.
	score_label_list.sort()
	name_label_list.sort()


func _update_high_score_ui() -> void:
	## Add the scores and names to the high scores screen
	for i : int in score_label_list.size():
		score_label_list[i].text = str(GameManager.player_hi_scores_dictionaries[i]["score"])
		name_label_list[i].text = GameManager.player_hi_scores_dictionaries[i]["name"]


####

## Signals connections

func _on_back_button_pressed() -> void:
	await UiUtility.selected_button_element_press_animation(back_button)
	back_button_pressed.emit()

func _on_back_button_mouse_entered() -> void:
	back_button.grab_focus()

func _on_back_button_focus_entered() -> void:
	UiUtility.highlight_selected_element([back_button], back_button)


func _on_visibility_changed() -> void:
	if self.visible:
		back_button.grab_focus()
		populate_high_scores_screen()
