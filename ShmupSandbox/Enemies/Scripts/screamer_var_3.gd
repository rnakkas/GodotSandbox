class_name ScreamerVar3 extends Node2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var shoot_timer: Timer = $shoot_timer
@onready var damage_taker_component: DamageTakerComponent = $DamageTakerComponent

@export var base_speed: float = 250.0
@export var max_speed: float = 510.0
@export var acceleration: float = 225.0
@export var deceleration: float = 80.0
@export var kill_score: int = 100
@export var shoot_time: float = 0.6

var speed: float
var velocity: Vector2
var direction: Vector2

## TODO: Spritesheets

################################################
# SCREAMER VARIANT 3
# Popcorn enemy
# Flies in from the right
# Fly in straight line from right to left
# Slow down and shoot when on screen
# Shoot at player position (targeted shooting)
# Then Accelerate to max speed to fly offscreen to the left
# Shoot once when on screen
################################################

################################################
# Ready
################################################
func _ready() -> void:
	speed = base_speed
	velocity = speed * Vector2.LEFT
	Helper.set_timer_properties(shoot_timer, true, shoot_time)
	_connect_to_signals()

func _connect_to_signals() -> void:
	damage_taker_component.damage_taken.connect(self._on_damage_taker_component_damage_taken)
	damage_taker_component.health_depleted.connect(self._on_damage_taker_component_health_depleted)


################################################
# Movement logic
################################################
func _physics_process(delta: float) -> void:
	if direction == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	if speed == max_speed:
		velocity = velocity.move_toward(speed * Vector2.LEFT, acceleration * delta)
	global_position += velocity * delta


################################################
# Slow down and start timer for shooting when on screen
################################################
func _on_screen_notifier_screen_entered() -> void:
	direction = Vector2.ZERO
	shoot_timer.start()


################################################
# Despawn after going offscreen
################################################
func _on_screen_notifier_screen_exited() -> void:
	call_deferred("queue_free")


################################################
# Shooting logic
################################################
func _on_shoot_timer_timeout() -> void:
	# Set speed to max to accelerate towards once shooting is done
	direction = Vector2.LEFT
	speed = max_speed


################################################
# Getting hit by player attacks logic:
	# Signal connections from damage taker component
################################################
func _on_damage_taker_component_damage_taken() -> void:
	SignalsBus.score_increased_event.emit(GameManager.attack_hit_score)

func _on_damage_taker_component_health_depleted() -> void:
	shoot_timer.stop()

	speed = speed / 2

	sprite.play("death")
	particles.emitting = true

	SignalsBus.score_increased_event.emit(kill_score)
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	await sprite.animation_finished

	call_deferred("queue_free")
