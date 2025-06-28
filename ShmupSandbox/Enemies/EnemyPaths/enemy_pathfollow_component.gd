class_name EnemyPathfollowComponent extends PathFollow2D

@export var pathfollow_speed : float = 0.1

func _ready() -> void:
	progress_ratio = 0.1

func _process(delta: float) -> void:
	progress_ratio += pathfollow_speed * delta
