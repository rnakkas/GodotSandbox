class_name ScreamerVar2 extends PathFollow2D

@onready var sprite : AnimatedSprite2D = %sprite
@onready var particles : CPUParticles2D = %CPUParticles2D

@export var kill_score : int = 100
@export var pathfollow_speed : float = 0.1

## TODO: Behaviour
# Variant 2: Fly in a sine wave path from right to left 
# while shooting single projectile straight forward

func _ready() -> void:
	progress_ratio = 0.0

func _process(delta: float) -> void:
	progress_ratio += pathfollow_speed * delta