class_name player_hud extends Control

@onready var score_label : Label = %score

var player_score : int = 0

func _ready() -> void:
	score_label.text = str(player_score).pad_zeros(8)
	_connect_to_signals()

func _connect_to_signals() -> void:
	SignalsBus.give_score_when_hit.connect(_on_hit_score_given)
	SignalsBus.give_score_when_killed.connect(_on_kill_score_given)

func _on_hit_score_given(score : int) -> void:
	player_score += score
	score_label.text = str(player_score).pad_zeros(8)

func _on_kill_score_given(score : int) -> void:
	player_score += score
	score_label.text = str(player_score).pad_zeros(8)
