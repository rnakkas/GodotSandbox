class_name SpawnEvent extends Resource

@export var time: float
@export var enemy_scene: PackedScene
@export var pos: Vector2
@export var path_name: String

func _init(p_time: float = 0, p_enemy_scene: PackedScene = null, p_pos: Vector2 = Vector2(0, 0), p_path_name: String = "") -> void:
	time = p_time
	enemy_scene = p_enemy_scene
	pos = p_pos
	path_name = p_path_name
