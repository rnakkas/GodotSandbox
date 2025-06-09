class_name DebugLayer extends Node2D

################################################
#NOTE:
	## Debug layer ##
	# For testing features quickly #
################################################

func _ready() -> void:
	pass

func _input(_event: InputEvent) -> void:
	# Only allow debug commands if using debug build
	if !OS.is_debug_build():
		return
	
	if Input.is_key_label_pressed(KEY_Q): # quit game
		get_tree().quit()
	
	if Input.is_key_label_pressed(KEY_R): # reset game
		get_tree().paused = false
		get_tree().reload_current_scene()
	
	if Input.is_key_label_pressed(KEY_1): # Spawn a powerup on mouse position
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		SignalsBus.spawn_powerup_event.emit(mouse_pos)
	
	if Input.is_key_label_pressed(KEY_2): # Add 1 bomb to stock
		if GameManager.player_bombs == GameManager.player_max_bombs:
			return
		GameManager.player_bombs += 1
		SignalsBus.player_bombs_updated_event.emit()
