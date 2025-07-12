class_name Rimshot extends Node2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var damage_taker_component: DamageTakerComponent = $DamageTakerComponent
@onready var screen_notifier: VisibleOnScreenNotifier2D = $screen_notifier
@onready var onscreen_timer: Timer = $onscreen_timer
@onready var shoot_timer: Timer = $shoot_timer

@export var kill_score: int = 150
@export var spawn_speed: float = 560.0
@export var fly_off_speed: float = 650.0
@export var acceleration: float = 900.0
@export var deceleration: float = 1200.0
@export var screen_time: float = 2.5

var speed: float
var direction: Vector2 = Vector2.ZERO
var velocity: Vector2


## TODO: Spritesheets and animations

################################################
# ENEMY: Rimshot
# Mid level fodder enemy
# Flies in from the top or bottom of the right side of screen
# If at bottom, flies diagonally to top left
# If at top, flies diagonally to bottom left
# Shoots vertically in + and - y direction, non targeted
# Despawn when offscreen
################################################

################################################
# Ready
################################################
func _ready() -> void:
	_connect_to_signals()

	Helper.set_timer_properties(onscreen_timer, true, screen_time)

	speed = spawn_speed

	# Set the direction so that enemy can move into screen from either top or bottom
	direction = self.global_position.direction_to(Vector2(self.global_position.x, 0))

	velocity = speed * direction


func _connect_to_signals() -> void:
	screen_notifier.screen_entered.connect(self._on_screen_entered)
	screen_notifier.screen_exited.connect(self._on_screen_exited)

	onscreen_timer.timeout.connect(self._on_onscreen_timer_timeout)

	damage_taker_component.damage_taken.connect(self._on_damage_taker_component_damage_taken)
	damage_taker_component.low_health.connect(self._on_damage_taker_component_low_health)
	damage_taker_component.health_depleted.connect(self._on_damage_taker_component_health_depleted)


################################################
# After entering screen
################################################
func _on_screen_entered() -> void:
	direction = Vector2.ZERO
	onscreen_timer.start()


################################################
# After exiting screen
################################################
func _on_screen_exited() -> void:
	await get_tree().create_timer(0.5).timeout
	call_deferred("queue_free")


################################################
# When screen time elapses:
	# If distance from current to top is greater than distacne from current to bottom:
		# Go to top left
	# If distance from current to top is lower than distance from current to bottom:
		# Go to bottom left
################################################
func _on_onscreen_timer_timeout() -> void:
	speed = fly_off_speed

	var viewport_size_y: float = get_viewport_rect().size.y
	var dist_to_top: float = abs(self.global_position.y - 0)
	var dist_to_bot: float = abs(self.global_position.y - viewport_size_y)

	if dist_to_top >= dist_to_bot:
		direction = self.global_position.direction_to(Vector2(35, 0))
	elif dist_to_top < dist_to_bot:
		direction = self.global_position.direction_to(Vector2(35, viewport_size_y))

	shoot_timer.start()

################################################
# Velocity logic
################################################
func _physics_process(delta: float) -> void:
	if direction == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	else:
		velocity = velocity.move_toward(speed * direction, acceleration * delta)
	
	global_position += velocity * delta


################################################
# Getting hit by player attacks logic:
	# Signal connections from damage taker component
################################################
func _on_damage_taker_component_damage_taken() -> void:
	SignalsBus.score_increased_event.emit(GameManager.attack_hit_score)

func _on_damage_taker_component_low_health() -> void:
	sprite.play("damaged")

func _on_damage_taker_component_health_depleted() -> void:
	sprite.play("death")
	particles.emitting = true

	# Stop all shooting timers
	shoot_timer.stop()

	speed = speed * 0.25

	SignalsBus.score_increased_event.emit(kill_score)
	
	# Signal to spawn score fragments on death
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	await sprite.animation_finished

	call_deferred("queue_free")
