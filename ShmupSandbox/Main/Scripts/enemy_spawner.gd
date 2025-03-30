class_name enemy_spawner extends Node2D

@export var enemy_scenes : Array[PackedScene] = []
@export var sp_tolerance : float = 128

## Timer
@onready var spawn_timer : Timer = $enemy_spawn_timer

## Custom signals
signal add_enemy_to_game(enemy : Area2D)

var sp_y : float = 50.0
var prev_sp : float
var prev_sp_list : Array[float] = []

var viewport_size : Vector2 

func _ready() -> void:
	viewport_size = get_viewport_rect().size
	prev_sp_list.resize(5)

func spawn_enemy() -> void:
	var enemy : Area2D = enemy_scenes.pick_random().instantiate()
	var sp : Vector2 = _get_spawn_point()
	enemy.global_position = sp
	
	add_enemy_to_game.emit(enemy)

func _get_spawn_point() -> Vector2:
	var too_close = true
	var sp_x : float
	
	while too_close:
		sp_x = randf_range(0 + sp_tolerance, viewport_size.x - sp_tolerance)
		too_close = false
		
		for i:int in range(min(5, prev_sp_list.size())):
			if abs(sp_x - prev_sp_list[i]) <= sp_tolerance:
				too_close = true
				break
	
	prev_sp_list.append(sp_x)
	if prev_sp_list.size() > 5:
		prev_sp_list.remove_at(0)
	
	
	#print(prev_sp_list.size())
	#print(prev_sp_list)
	#
	#for i:int in range(prev_sp_list.size() - 1):
		#if abs(sp_x - prev_sp_list[i]) <= sp_tolerance:
			#sp_x = randf_range(0 + sp_tolerance, viewport_size.x - sp_tolerance)
			#_populate_prev_sp_list(sp_x)
			#break
	
	
	#prev_sp = sp_x
	#
	### When new sp is on the right of previous sp
	#if sp_x <= prev_sp + sp_tolerance:
		#sp_x = sp_x + sp_tolerance
		### Stay within screen bounds
		#if sp_x >= viewport_size.x:
			#sp_x = viewport_size.x - sp_tolerance
	### When new sp is on left of previous sp
	#elif sp_x >= prev_sp - sp_tolerance:
		#sp_x = sp_x - sp_tolerance
		### Stay within screen bounds
		#if sp_x <= 0:
			#sp_x = sp_tolerance

	return Vector2(sp_x, sp_y)

func _populate_prev_sp_list(sp_x : float) -> void:
	if prev_sp_list.size() >= 3:
		prev_sp_list.pop_front()
	prev_sp_list.append(sp_x)

## Spawn enemies on timeout
func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()
