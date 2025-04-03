class_name main extends Node2D


var game_scene : PackedScene = preload("res://ShmupSandbox/Main/Scenes/game.tscn")

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	## For testing only
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("reset"):
		get_tree().paused = false
		get_tree().reload_current_scene()

func _on_ui_layer_game_started() -> void:
	_start_game()


## Helper functions
func _start_game() -> void:
	var game_instance := game_scene.instantiate()
	add_child(game_instance)
