class_name player_hud extends Control

@onready var score_value : Label = %score_value
@onready var player_lives_value : Label = %lives_value

func _ready() -> void:
	score_value.text = str(PlayerData.player_score).pad_zeros(8)
	_connect_to_signals()

func _connect_to_signals() -> void:
	SignalsBus.give_score_when_hit.connect(_on_hit_score_given)
	SignalsBus.give_score_when_killed.connect(_on_kill_score_given)
	SignalsBus.player_died.connect(_on_player_death)

func _on_hit_score_given(score : int) -> void:
	PlayerData.player_score += score
	score_value.text = str(PlayerData.player_score).pad_zeros(8)

func _on_kill_score_given(score : int) -> void:
	PlayerData.player_score += score
	score_value.text = str(PlayerData.player_score).pad_zeros(8)

func _on_player_death() -> void:
	PlayerData.player_lives -= 1
	if PlayerData.player_lives >= 0:
		player_lives_value.text = "x " + str(PlayerData.player_lives)
	else: 
		SignalsBus.player_lives_depleted_event()
	
