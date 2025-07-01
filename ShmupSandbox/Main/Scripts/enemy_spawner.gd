class_name EnemySpawner extends Node2D

################################################################################################################
#
## FIXME: This enemy spawner be cleaned up once I figure out creating spawn schedules using json or resources
#
# Currently thinking to design in this way:
	# - enemy spawner holds packed scenes for all the enemies in the game
	# - will have a function like spawn_enemy(enemy_scene : PackedScene)
	# - this function instantiates the enemy, sets its initial position etc
	# - it then emits signal to Game to add enemy to enemies container in game
	# - When i have enemy schedules ready for each level (either a json or resource file)
	#		- enemy spawner will read that schedule
	#		- based on the schdule it will run the spawn_enemy(enemy_scene) function to instantiate enemies
	# - will also connect to global signals to spawn enemies: SignalsBus.spawn_enemy_x_event(sp: Vector2)
	#
	# - Will also hold packed scenes for all enemy paths
	# - will have a function like spawn_path(path_scene : PackedScene)
	# - will connect to global signals to spawn paths
################################################################################################################

@export var enemy_scenes : Array[PackedScene] = []
@export var sp_tolerance : float = 128

## Timer
@onready var spawn_timer : Timer = $enemy_spawn_timer

## Custom signals
signal add_enemy_to_game(enemy : Node2D)
signal add_pathfollow_enemy_to_game(enemy : PathFollow2D, path : Path2D)

var sp_x : float
var prev_sp : float
var prev_sp_list : Array[float] = []

var viewport_size : Vector2 

func _ready() -> void:
	_connect_to_signals()

	viewport_size = get_viewport_rect().size
	prev_sp_list.resize(5)
	sp_x = viewport_size.x + 50.0


func _connect_to_signals() -> void:
	SignalsBus.spawn_enemy_doomboard_event.connect(self._on_spawn_doomboard_event)
	SignalsBus.spawn_enemy_boomer_event.connect(self._on_spawn_boomer_event)
	SignalsBus.spawn_enemy_screamer_1_event.connect(self._on_spawn_screamer_1_event)
	SignalsBus.spawn_enemy_screamer_2_event.connect(self._on_spawn_screamer_2_event)
	SignalsBus.spawn_enemy_screamer_3_event.connect(self._on_spawn_screamer_3_event)


func _on_spawn_doomboard_event(sp : Vector2) -> void:
	_instantiate_enemy(SceneManager.doomboard_PS, sp)

func _on_spawn_boomer_event(sp : Vector2) -> void:
	_instantiate_enemy(SceneManager.boomer_PS, sp)

func _on_spawn_screamer_1_event(sp : Vector2) -> void:
	_instantiate_enemy(SceneManager.screamer_1_PS, sp)

func _on_spawn_screamer_2_event(path : Path2D) -> void:
	_instantiate_pathfollow_enemy(SceneManager.screamer_2_PS, path)

func _on_spawn_screamer_3_event(sp: Vector2) -> void:
	_instantiate_enemy(SceneManager.screamer_3_PS, sp)


func _instantiate_enemy(enemy_scene: PackedScene, sp : Vector2) -> void:
	var enemy_instance : Node2D = enemy_scene.instantiate()
	enemy_instance.global_position = sp
	add_enemy_to_game.emit(enemy_instance)

func _instantiate_pathfollow_enemy(enemy_scene : PackedScene, path : Path2D) -> void:
	var enemy_instance : PathFollow2D = enemy_scene.instantiate()
	add_pathfollow_enemy_to_game.emit(enemy_instance, path)


####################################
####################################

func spawn_enemy() -> void:
	var enemy : Area2D = enemy_scenes.pick_random().instantiate()
	var sp : Vector2 = _generate_spawn_point()
	enemy.global_position = sp
	
	add_enemy_to_game.emit(enemy)

func _generate_spawn_point() -> Vector2:
	var too_close : bool = true
	var sp_y : float
	
	## Check that the spawn point is not too close to the last 5 spawn points
	##	to prevent enemies overlapping as much as possible
	while too_close:
		sp_y = randf_range(0 + sp_tolerance, viewport_size.y - sp_tolerance)
		too_close = false
		
		for i:int in range(min(5, prev_sp_list.size())):
			if abs(sp_y - prev_sp_list[i]) <= sp_tolerance:
				too_close = true
				break
	
	prev_sp_list.append(sp_y)
	if prev_sp_list.size() > 5:
		prev_sp_list.remove_at(0)

	return Vector2(sp_x, sp_y)

## Spawn enemies on timeout
func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()
