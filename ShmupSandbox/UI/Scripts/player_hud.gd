class_name PlayerHud extends Control

@onready var score_value : Label = %score_value
@onready var player_lives_value : Label = %lives_value
@onready var top_score_value : Label = %top_score_value

func _ready() -> void:
	_connect_to_signals()

## Helper funcs
func _connect_to_signals() -> void:
	SignalsBus.player_score_updated.connect(_on_player_score_updated)
	SignalsBus.player_lives_updated.connect(_on_player_lives_updated)


func set_score_values_on_hud() -> void:
	score_value.text = str(PlayerData.player_score).pad_zeros(10)
	top_score_value.text = str(PlayerData.player_hi_scores_dictionaries[0]["score"]).pad_zeros(10)

####

## Signals connections

func _on_player_score_updated() -> void:
	score_value.text = str(PlayerData.player_score).pad_zeros(10)

	## If cuurent score is higher than top, show current score in Top
	if PlayerData.player_score > PlayerData.player_hi_scores_dictionaries[0]["score"]:
		top_score_value.text = str(PlayerData.player_score).pad_zeros(10)
	## If current score is lower than top, show Top
	elif PlayerData.player_score <= PlayerData.player_hi_scores_dictionaries[0]["score"]:
		top_score_value.text = str(PlayerData.player_hi_scores_dictionaries[0]["score"]).pad_zeros(10)


func _on_player_lives_updated() -> void:
	if PlayerData.player_lives >= 0:
		player_lives_value.text = "x " + str(PlayerData.player_lives)
	

func _on_visibility_changed() -> void:
	if self.visible:
		set_score_values_on_hud()
