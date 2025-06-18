class_name Doomboard extends Area2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var particles : CPUParticles2D = $CPUParticles2D

@export var speed : float = 100.0
@export var health : int = 10

## TODO:
	# - spawn offscreen right side
	# - when spawned offscreen, move at a faster speed until on screen
	# - when onscreen, move at a slower speed towards the left
	# - when offscreen right, despawn
	# - when hit, take damage
	# - if below 50% health, play damaged animation instead of idle
	# - if health depleted, dies and play death animation
	# - on death, signal to spawn powerup at death position

func _physics_process(delta: float) -> void:
	global_position += speed * delta * Vector2.LEFT
