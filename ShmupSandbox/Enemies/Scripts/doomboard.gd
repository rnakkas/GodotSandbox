class_name Doomboard extends Area2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var particles : CPUParticles2D = $CPUParticles2D

const offscreen_speed : float = 350.0
const onscreen_speed : float = 100.0

@export var speed : float = offscreen_speed
@export var health : int = 10

## TODO:
	# - spawn offscreen right side - TODO: awaiting spawn scheduler work
	# - when spawned offscreen, move at a faster speed until on screen - DONE
	# - when offscreen cannot be damaged, disable collisions - DONE
	# - when on screen, enable collisions - DONE
	# - when onscreen, move at a slower speed towards the left - DONE
	# - timer: on timeout move towards center of player's y coordinates
	# - when offscreen right, despawn - DONE
	# - when hit, take damage
	# - if below 50% health, play damaged animation instead of idle
	# - if health depleted, dies and play death animation
	# - on death, signal to spawn powerup at death position


func _ready() -> void:
	# Disable collisions when spawned, will be enabled when it enters screen
	# To prevent being prematurely killed
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)


func _physics_process(delta: float) -> void:
	global_position += speed * delta * Vector2.LEFT


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	speed = onscreen_speed

	# Enable collisions when on screen, to be able to be hurt/killed
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Despawn when it leaves screen
	call_deferred("queue_free")
