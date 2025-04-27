class_name HiScoresMenu extends Control

@onready var back_button : Button = %back_button

@export var score_label_list : Array[Label]

signal back_button_pressed()

func _ready() -> void:

	score_label_list.sort()
	print("score labels list: ", score_label_list, "\n")

	## Sets the score label's text TODO:
	for score: int in PlayerData.player_hi_scores_list.size():
		print("score: ", PlayerData.player_hi_scores_list[score])
		


####

## Signals connections

func _on_back_button_pressed() -> void:
	await UiUtility.selected_button_element_press_animation(back_button)
	back_button_pressed.emit()

func _on_back_button_mouse_entered() -> void:
	back_button.grab_focus()

func _on_back_button_focus_entered() -> void:
	UiUtility.highlight_selected_element([back_button], back_button)
