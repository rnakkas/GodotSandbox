class_name ScreamerVar2 extends PathFollow2D

@onready var sprite: AnimatedSprite2D = %sprite
@onready var particles: CPUParticles2D = %CPUParticles2D
@onready var shooting_timer: Timer = $shooting_timer

@export var kill_score: int = 100
@export var pathfollow_speed: float = 0.28

## TODO: Spritesheets

################################################
# SCREAMER VARIANT 2
# Popcorn enemy
# Flies in a set path from right to left
# Shoots once in a straight line to the left when on screen
################################################

################################################
# Ready
################################################
func _ready() -> void:
	progress_ratio = 0.0


################################################
# Physics process for moving in path
################################################
func _physics_process(delta: float) -> void:
	progress_ratio += pathfollow_speed * delta


################################################
# Start shooting timer when onscreen
################################################
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	shooting_timer.start()


################################################
# Despawn after going offscreen
################################################
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	shooting_timer.stop()
	call_deferred("queue_free")


################################################
# Getting hit by player attacks logic:
#	Signal connections from damage taker component
################################################
func _on_damage_taker_component_health_depleted() -> void:
	pathfollow_speed = pathfollow_speed / 2

	sprite.play("death")
	particles.emitting = true

	SignalsBus.score_increased_event.emit(kill_score)
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	await sprite.animation_finished

	call_deferred("queue_free")
