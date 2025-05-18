class_name Main extends Node2D


var game_scene : PackedScene = preload("res://ShmupSandbox/Main/Scenes/game.tscn")
var game_instance : Node


################################################
#NOTE: Ready
################################################
func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS


################################################
#NOTE: Game started signal from ui
################################################
func _on_ui_layer_game_started() -> void:
	_start_game()

func _start_game() -> void:
	GameManager.reset_all_player_data_on_start()
	game_instance = game_scene.instantiate()
	add_child(game_instance)


################################################
#NOTE: Return to main menu, kill game instance signal from ui
################################################
func _on_ui_layer_kill_game_instance() -> void:
	game_instance.call_deferred("queue_free")

