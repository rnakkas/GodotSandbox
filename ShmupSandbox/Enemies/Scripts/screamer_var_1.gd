class_name ScreamerVar1 extends Node2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var onscreen_timer: Timer = $onscreen_timer
@onready var shoot_timer: Timer = $shoot_timer

@export var base_speed: float = 500.0
@export var acceleration: float = 600.0
@export var deceleration: float = 610.0
@export var kill_score: int = 100
@export var max_onscreen_time: float = 8.0
@export var min_onscreen_time: float = 5.0
@export var shoot_time: float = 1.8

var speed: float
var onscreen_time: float
var direction: Vector2 = Vector2.LEFT
var velocity: Vector2

## TODO: Spritesheets

################################################
# SCREAMER VARIANT 1
# Popcorn enemy
# Flies in from the right
# Slows to a stop
# Stays on screen for 5 - 8 seconds
# Shoots as long as on screen
# Flies off back to the right after screen time elapses
################################################

################################################
# NOTE: Ready
################################################
func _ready() -> void:
	speed = base_speed
	onscreen_time = randf_range(min_onscreen_time, max_onscreen_time)
	Helper.set_timer_properties(onscreen_timer, true, onscreen_time)
	Helper.set_timer_properties(shoot_timer, false, shoot_time)


################################################
# NOTE: Physics process for movement
################################################
func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	global_position += velocity * delta


################################################
# NOTE: Start timers for screen time and shooting
################################################
func _on_onscreen_notifier_screen_entered() -> void:
	onscreen_timer.start()
	shoot_timer.start(shoot_time / 6)
	shoot_timer.wait_time = shoot_time
	direction = Vector2.ZERO
	deceleration = randf_range(deceleration / 2, deceleration * 1.5)


################################################
# NOTE: Screen time elapses, fly off
################################################
func _on_onscreen_timer_timeout() -> void:
	shoot_timer.stop()
	var viewport_size: Vector2 = get_viewport_rect().size
	var dir_y: float = randf_range(0, viewport_size.y)
	direction = self.global_position.direction_to(Vector2(viewport_size.x, dir_y))


################################################
# NOTE: Despawn after going offscreen
################################################
func _on_offscreen_notifier_screen_exited() -> void:
	call_deferred("queue_free")


################################################
# NOTE: Getting hit by player attacks logic:
	# Signal connections from damage taker component
################################################
func _on_damage_taker_component_health_depleted() -> void:
	shoot_timer.stop()

	speed = speed / 2

	sprite.play("death")
	particles.emitting = true

	SignalsBus.score_increased_event.emit(kill_score)
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	await sprite.animation_finished

	call_deferred("queue_free")
