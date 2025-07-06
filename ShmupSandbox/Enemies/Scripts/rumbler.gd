class_name Rumbler extends Node2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var onscreen_timer: Timer = $onscreen_timer
@onready var shoot_timer: Timer = $shoot_timer

@export var offscreen_speed: float = 400.0
@export var onscreen_speed: float = 50.0
@export var acceleration: float = 600.0
@export var deceleration: float = 1500.0
@export var kill_score: int = 250
@export var screen_time: float = 10.0

var direction: Vector2 = Vector2.LEFT
var velocity: Vector2
var activated: bool

## TODO: Spritesheets
## TODO: Shooting logic

################################################
# NOTE: Rumbler
# Slow moving area denial enemy
# Flies in from the right
# Slows down to onscreen speed
# Shoots 3 projectiles at the player
# Stays onscreen for about 10 seconds
# Shoots at the player approx 3-4 times when on screen
# After onscreen time elapses, speeds up and flies offscreen to the left
################################################

################################################
# NOTE: Ready
################################################
func _ready() -> void:
	velocity = offscreen_speed * direction
	Helper.set_timer_properties(onscreen_timer, true, screen_time)


################################################
# NOTE: Movement logic
################################################
func _physics_process(delta: float) -> void:
	if activated:
		velocity = velocity.move_toward(onscreen_speed * direction, deceleration * delta)
	else:
		velocity = velocity.move_toward(offscreen_speed * direction, acceleration * delta)
	
	global_position += velocity * delta


################################################
# NOTE: Activate after appearing on screen
################################################
func _on_screen_notifier_screen_entered() -> void:
	activated = true
	onscreen_timer.start()
	shoot_timer.start()


################################################
# NOTE: Despawn after going offscreen
################################################
func _on_screen_notifier_screen_exited() -> void:
	call_deferred("queue_free")


################################################
# NOTE: Deactivate after on screen time elapses
################################################
func _on_onscreen_timer_timeout() -> void:
	activated = false
	shoot_timer.stop()


################################################
# NOTE: Getting hit by player attacks logic:
	# Signal connections from damage taker component
################################################
func _on_damage_taker_component_damage_taken() -> void:
	SignalsBus.score_increased_event.emit(GameManager.attack_hit_score)

func _on_damage_taker_component_low_health() -> void:
	sprite.play("damaged")

func _on_damage_taker_component_health_depleted() -> void:
	sprite.play("death")
	particles.emitting = true

	SignalsBus.score_increased_event.emit(kill_score)
	
	# Signal to spawn score fragments on death
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	await sprite.animation_finished

	call_deferred("queue_free")
