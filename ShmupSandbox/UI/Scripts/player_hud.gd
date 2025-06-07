class_name PlayerHud extends Control

@onready var score_value : Label = %score_value
@onready var player_lives_value : Label = %lives_value
@onready var top_score_value : Label = %top_score_value
@onready var credits_value : Label = %credits_value

## TODO: Update this with the player bombs

################################################
#NOTE: Ready
################################################
func _ready() -> void:
	_connect_to_signals()

func _connect_to_signals() -> void:
	SignalsBus.player_score_updated.connect(_on_player_score_updated)
	SignalsBus.player_lives_updated.connect(_on_player_lives_updated)
	SignalsBus.player_credits_updated.connect(_on_player_credits_updated)


################################################
#NOTE: When player hud becomes visible
################################################
func _on_visibility_changed() -> void:
	if self.visible:
		set_score_values_on_hud()

func set_score_values_on_hud() -> void:
	score_value.text = str(GameManager.player_score).pad_zeros(10)
	top_score_value.text = str(GameManager.player_hi_scores_dictionaries[0]["score"]).pad_zeros(10)


################################################
#NOTE: Signal connections
################################################
func _on_player_score_updated() -> void:
	score_value.text = str(GameManager.player_score).pad_zeros(10)

	## If cuurent score is higher than top, show current score in Top
	if GameManager.player_score > GameManager.player_hi_scores_dictionaries[0]["score"]:
		top_score_value.text = str(GameManager.player_score).pad_zeros(10)
	## If current score is lower than top, show Top
	elif GameManager.player_score <= GameManager.player_hi_scores_dictionaries[0]["score"]:
		top_score_value.text = str(GameManager.player_hi_scores_dictionaries[0]["score"]).pad_zeros(10)


func _on_player_lives_updated() -> void:
	if GameManager.player_lives >= 0:
		player_lives_value.text = "x " + str(GameManager.player_lives)
	

func _on_player_credits_updated() -> void:
	if GameManager.player_credits >= 0:
		credits_value.text = str(GameManager.player_credits)



