class_name DebugLayer extends Node2D

################################################
#NOTE:
	## Debug layer ##
	# For testing features quickly #
################################################

@onready var debug_label : Label = $debug_label
@onready var info_label: Label = $info_label
@onready var player_collisions_label : Label = $player_collisions_label

func _ready() -> void:
	_show_debug_label()
	_hide_debug_console()

func _show_debug_label() -> void:
	if !OS.is_debug_build():
		debug_label.visible = false


func _show_debug_console() -> void:
	info_label.visible = true
	player_collisions_label.visible = true

func _hide_debug_console() -> void:
	info_label.visible = false
	player_collisions_label.visible = false


func _input(_event: InputEvent) -> void:
	# Only allow debug commands if using debug build
	if !OS.is_debug_build():
		return
	
	# Show or hide debug console info
	if Input.is_key_label_pressed(KEY_QUOTELEFT):
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			_show_debug_console()
		else:
			_hide_debug_console()

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
	
	if Input.is_key_label_pressed(KEY_3): # Turn off player collisions
		print_debug("player hurtbox: OFF")
		
		var player : PlayerCat = get_tree().get_first_node_in_group("DEBUG_player_group")
		
		if player != null:
			var player_hurtbox : Area2D =  player.get_node("hurtbox")
			player_hurtbox.set_deferred("monitorable", false)
			player_hurtbox.set_deferred("monitoring", false)
			player_collisions_label.text = "Player Collisions: OFF"
	
	if Input.is_key_label_pressed(KEY_4): # Turn on player collisions
		print_debug("player hurtbox: ON")

		var player : PlayerCat = get_tree().get_first_node_in_group("DEBUG_player_group")
		
		if player != null:
			var player_hurtbox : Area2D =  player.get_node("hurtbox")
			player_hurtbox.set_deferred("monitorable", true)
			player_hurtbox.set_deferred("monitoring", true)
			player_collisions_label.text = "Player Collisions: ON"
		
	if Input.is_key_label_pressed(KEY_5): # Spawn score item
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		SignalsBus.spawn_score_item_event.emit(mouse_pos)

	if Input.is_key_label_pressed(KEY_6): # Spawn score fragment
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		SignalsBus.spawn_score_fragment_event.emit(mouse_pos)
	
	if Input.is_key_label_pressed(KEY_7): # Spawn enemy - Doom Board
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		SignalsBus.spawn_enemy_doomboard_event.emit(mouse_pos)

	if Input.is_key_label_pressed(KEY_8): # Spawn enemy - Boomer
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		SignalsBus.spawn_enemy_boomer_event.emit(mouse_pos)