class_name DebugLayer extends CanvasLayer

################################################
#NOTE:
	## Debug layer ##
	# For testing features quickly #
################################################

@onready var debug_label: Label = $debug_label
@onready var info_label: Label = $info_label
@onready var player_collisions_label: Label = $player_collisions_label
@onready var x_coord: TextEdit = $x_coord
@onready var y_coord: TextEdit = $y_coord
@onready var enemy_paths_options: OptionButton = $enemy_paths_options

var debug_ui_elements: Array[Node] = []
# var enemy_paths_list : Array[Path2D] = []
var pos: Vector2
var current_player_debug_option: int
var current_enemy_spawn_option: int
var current_enemy_path_option: int


################################################
#NOTE: Ready
################################################
func _ready() -> void:
	_show_debug_label()
	_get_debug_ui_elements()
	_hide_debug_console()

func _show_debug_label() -> void:
	if !OS.is_debug_build():
		return
	debug_label.visible = true
	self.visible = true

func _get_debug_ui_elements() -> void:
	if !OS.is_debug_build():
		return
	debug_ui_elements = get_tree().get_nodes_in_group("DEBUG_ui_group")


################################################
#NOTE: Helpers to show or hide debug console
################################################
func _show_debug_console() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for element: Node in debug_ui_elements:
		element.visible = true

func _hide_debug_console() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	for element: Node in debug_ui_elements:
		element.visible = false


################################################
#NOTE: Input processing
################################################
func _input(_event: InputEvent) -> void:
	# Only allow debug commands if using debug build
	if !OS.is_debug_build():
		return
	
	# Show or hide debug console info
	if Input.is_key_label_pressed(KEY_QUOTELEFT):
		_create_enemy_paths_list()
		
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


func _create_enemy_paths_list() -> void:
	# enemy_paths_list = [
	# 	GameManager.enemy_path_sine_wave_1,
	# 	GameManager.enemy_path_sine_wave_2,
	# 	GameManager.enemy_path_sine_wave_3,
	# 	GameManager.enemy_path_sine_wave_4,
	# 	GameManager.enemy_path_sine_wave_5,
	# 	GameManager.enemy_path_sine_wave_6,
	# 	GameManager.enemy_path_sine_wave_v2_1,
	# ]
	# enemy_paths_list.sort()
	GameManager.enemy_paths_list.sort()

	if enemy_paths_options.item_count == (GameManager.enemy_paths_list.size() + 1):
		return
	
	for i: int in range(GameManager.enemy_paths_list.size()):
		if GameManager.enemy_paths_list[i] == null:
			return
		enemy_paths_options.add_item(GameManager.enemy_paths_list[i].name)


################################################
#NOTE: Signals for selecting items in the drop down option menus
################################################
func _on_player_debug_options_item_selected(index: int) -> void:
	current_player_debug_option = index


func _on_enemy_spawn_debug_options_item_selected(index: int) -> void:
	current_enemy_spawn_option = index
	
	# Choose default path if no path selected for the pathed enemies
	current_enemy_path_option = 1
		

func _on_enemy_paths_options_item_selected(index: int) -> void:
	current_enemy_path_option = index


################################################
#NOTE: Signal for OK button to confirm options
################################################
func _on_ok_button_pressed() -> void:
	pos = Vector2(x_coord.text.to_float(), y_coord.text.to_float())
	_player_debug_actions()
	_enemy_spawn_actions()


################################################
#NOTE: Action the player debug options
################################################
func _player_debug_actions() -> void:
	match current_player_debug_option:
		0: # None
			return
		
		1: # Spawn poerup
			SignalsBus.spawn_powerup_event.emit(pos)
		
		2: # Add 1 bomb to stock
			if GameManager.player_bombs == GameManager.player_max_bombs:
				return
			GameManager.player_bombs += 1
			SignalsBus.player_bombs_updated_event.emit()
		
		3: # Player collisions OFF
			if GameManager.player != null:
				var player_hurtbox: Area2D = GameManager.player.get_node("hurtbox")
				player_hurtbox.set_deferred("monitorable", false)
				player_hurtbox.set_deferred("monitoring", false)
				player_collisions_label.text = "Player Collisions: OFF"
		
		4: # Player collisions ON
			if GameManager.player != null:
				var player_hurtbox: Area2D = GameManager.player.get_node("hurtbox")
				player_hurtbox.set_deferred("monitorable", true)
				player_hurtbox.set_deferred("monitoring", true)
				player_collisions_label.text = "Player Collisions: ON"

		5: # Spawn score item
			SignalsBus.spawn_score_item_event.emit(pos)
		
		6: # Spawn score fragment
			SignalsBus.spawn_score_fragment_event.emit(pos)
		

################################################
#NOTE: Action the enemy spawn debug actions
################################################
func _enemy_spawn_actions() -> void:
	match current_enemy_spawn_option:
		0: # None
			return
		
		1: # Spawn Doomboard
			SignalsBus.spawn_enemy_doomboard_event.emit(pos)
		
		2: # Spawn Boomer
			SignalsBus.spawn_enemy_boomer_event.emit(pos)
		
		3: # Spawn Screamer variant 1
			SignalsBus.spawn_enemy_screamer_1_event.emit(pos)
		
		4: # Spawn Screamer variant 2
			SignalsBus.spawn_enemy_screamer_2_event.emit(_get_enemy_path())
		
		5: # Spawn Screamer variant 3
			SignalsBus.spawn_enemy_screamer_3_event.emit(pos)
		
		6: # Spawn Soul Carrier
			SignalsBus.spawn_enemy_soul_carrier_event.emit(pos)
		
		7: # Spawn Rumbler
			SignalsBus.spawn_enemy_rumbler_event.emit(pos)
		
		8: # Spawn Vile V
			SignalsBus.spawn_enemy_vile_v_event.emit(pos)
		
		9: # Spawn Axecutioner
			SignalsBus.spawn_enemy_axecutioner_event.emit(pos)
		
		10: # Spawn Bass Behemoth
			SignalsBus.spawn_enemy_bass_behemoth_event.emit(pos)
		
		11: # Spawn Rimshot
			SignalsBus.spawn_enemy_rimshot_event.emit(pos)


################################################
#NOTE: Helper to get the enemy path value
################################################
func _get_enemy_path() -> Path2D:
	match current_enemy_path_option:
		0: # None
			return
		
		1: # Sine wave 1
			return _get_path_from_list(GameManager.enemy_path_sine_wave_1)
		
		2: # Sine wave 2
			return _get_path_from_list(GameManager.enemy_path_sine_wave_2)

		3: # Sine wave 3
			return _get_path_from_list(GameManager.enemy_path_sine_wave_3)
		
		4: # Sine wave 4
			return _get_path_from_list(GameManager.enemy_path_sine_wave_4)

		_:
			return

func _get_path_from_list(path_name: String) -> Path2D:
	var enemy_path: Path2D
	for path: Path2D in GameManager.enemy_paths_list:
		if path.name == path_name:
			enemy_path = path
			break
	return enemy_path