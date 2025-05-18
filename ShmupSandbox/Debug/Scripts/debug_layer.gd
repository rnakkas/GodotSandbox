class_name DebugLayer extends Node2D

################################################
#NOTE:
	## Debug layer ##
	# For testing features quickly #
################################################

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
	if event.is_action_pressed("reset"):
		get_tree().paused = false
		get_tree().reload_current_scene()
