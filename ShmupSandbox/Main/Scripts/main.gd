class_name main extends Node2D


var game_scene : PackedScene = preload("res://ShmupSandbox/Main/Scenes/game.tscn")
var game_instance : Node

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	## For testing only
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	## For testing only
	if Input.is_action_just_pressed("reset"):
		get_tree().paused = false
		get_tree().reload_current_scene()


func _on_ui_layer_game_started() -> void:
	_start_game()

func _on_ui_layer_returned_to_main_menu_from_game() -> void:
	game_instance.call_deferred("queue_free")


## Helper functions
func _start_game() -> void:
	_reset_player_data()
	game_instance = game_scene.instantiate()
	add_child(game_instance)

func _reset_player_data() -> void:
	## Reset player data
	PlayerData.player_score = 0
	PlayerData.enemies_killed = 0
	PlayerData.player_lives = 3
