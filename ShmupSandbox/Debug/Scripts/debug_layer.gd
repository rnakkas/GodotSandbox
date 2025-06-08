class_name DebugLayer extends Node2D

################################################
#NOTE:
	## Debug layer ##
	# For testing features quickly #
################################################

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	# Only allow debug commands if using debug build
	if !OS.is_debug_build():
		return
	
	if event.is_action_pressed("quit"): # quit game
		get_tree().quit()
	if event.is_action_pressed("reset"): # reset game
		get_tree().paused = false
		get_tree().reload_current_scene()
	if Input.is_key_label_pressed(KEY_1): # Spawn a powerup on mouse position
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		SignalsBus.spawn_powerup_event.emit(mouse_pos)
