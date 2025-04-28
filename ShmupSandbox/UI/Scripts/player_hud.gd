class_name PlayerHud extends Control

@onready var score_value : Label = %score_value
@onready var player_lives_value : Label = %lives_value
@onready var top_score_value : Label = %top_score_value

func _ready() -> void:
	_connect_to_signals()

## Helper funcs
func _connect_to_signals() -> void:
	SignalsBus.give_score_when_hit.connect(_on_hit_score_given)
	SignalsBus.give_score_when_killed.connect(_on_kill_score_given)
	SignalsBus.player_died.connect(_on_player_death)


func set_score_values_on_hud() -> void:
	score_value.text = str(PlayerData.player_score).pad_zeros(10)

	PlayerData.sort_high_scores()
	top_score_value.text = str(PlayerData.player_hi_scores_dictionaries[0]["score"]).pad_zeros(10)

####

## Signals connections

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
	

func _on_visibility_changed() -> void:
	if self.visible:
		set_score_values_on_hud()
