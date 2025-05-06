class_name Main extends Node2D


var game_scene : PackedScene = preload("res://ShmupSandbox/Main/Scenes/game.tscn")
var game_instance : Node

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	## FIXME: For testing only, remove later
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	## FIXME: For testing only, remove later
	if Input.is_action_just_pressed("reset"):
		get_tree().paused = false
		get_tree().reload_current_scene()


func _on_ui_layer_game_started() -> void:
	_start_game()

func _on_ui_layer_kill_game_instance() -> void:
	game_instance.call_deferred("queue_free")


## Helper functions
func _start_game() -> void:
	GameManager.reset_all_player_data_on_start()
	game_instance = game_scene.instantiate()
	add_child(game_instance)
