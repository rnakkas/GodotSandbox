class_name EnemySpawner extends Node2D

################################################################################################################
#
## FIXME: This enemy spawner be cleaned up once I figure out creating spawn schedules using json or resources
#
################################################################################################################

@export var enemy_scenes : Array[PackedScene] = []
@export var sp_tolerance : float = 128

@export var doomboard_packed_scene : PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/doomboard.tscn")

## Timer
@onready var spawn_timer : Timer = $enemy_spawn_timer

## Custom signals
signal add_enemy_to_game(enemy : Area2D)

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


func _on_spawn_doomboard_event(sp : Vector2) -> void:
	var doomboard : Area2D = doomboard_packed_scene.instantiate()
	doomboard.global_position = sp
	add_enemy_to_game.emit(doomboard)



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
