class_name enemy_spawner extends Node2D

@export var enemy_scenes : Array[PackedScene] = []
@export var sp_tolerance : float = 32

## Timer
@onready var spawn_timer : Timer = $enemy_spawn_timer

## Custom signals
signal add_enemy_to_game(enemy : Area2D)

var sp_y : float = 50.0
var prev_sp : float

var viewport_size : Vector2 

func _ready() -> void:
	viewport_size = get_viewport_rect().size

func _get_spawn_point() -> Vector2:
	var sp_x : float = randf_range(0, viewport_size.x)
	prev_sp = sp_x
	
	## When new sp is on the right of previous sp
	if sp_x <= prev_sp + sp_tolerance:
		sp_x = sp_x + sp_tolerance
		## Stay within screen bounds
		if sp_x >= viewport_size.x:
			sp_x = viewport_size.x - sp_tolerance
	## When new sp is on left of previous sp
	elif sp_x >= prev_sp - sp_tolerance:
		sp_x = sp_x - sp_tolerance
		## Stay within screen bounds
		if sp_x <= 0:
			sp_x = sp_tolerance

	return Vector2(sp_x, sp_y)

func spawn_enemy() -> void:
	var enemy : Area2D = enemy_scenes.pick_random().instantiate()
	var sp : Vector2 = _get_spawn_point()
	enemy.global_position = sp
	
	add_enemy_to_game.emit(enemy)

## Spawn enemies on timeout
func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()
