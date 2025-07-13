class_name Tomblaster extends Node2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var damage_taker_component: DamageTakerComponent = $DamageTakerComponent
@onready var screen_notifier: VisibleOnScreenNotifier2D = $screen_notifier
@onready var onscreen_timer: Timer = $onscreen_timer
@onready var shoot_control_timer: Timer = $shoot_control_timer
@onready var shoot_timer: Timer = $shoot_timer
@onready var shooting_component: EnemyShootingComponent = $EnemyShootingComponent

@export var kill_score: int = 150
@export var spawn_speed: float = 560.0
@export var fly_off_speed: float = 650.0
@export var acceleration: float = 900.0
@export var deceleration: float = 330.0
@export var screen_time: float = 1.2
@export var shoot_control_time: float = 0.8
@export var shot_angle_rotation_step_deg: float = 10.0

var speed: float
var direction: Vector2
var velocity: Vector2
var viewport_size: Vector2
var spawn_pos: Vector2


## TODO: Spritesheets and animations

################################################
# ENEMY: Tomblaster
# Mid level enemy
# Flies in from the top or bottom of the left side of screen diagonally
# Flies into screen towards center of viewport
# Stops at viewport center
# Shoots multiple times in x=-1 direction, non targeted, with a rotating muzzle
# Accelerates to fly off towards opposite corner of spawn
# Despawn when offscreen
################################################

################################################
# Ready
################################################
func _ready() -> void:
	_connect_to_signals()
	
	Helper.set_timer_properties(onscreen_timer, true, screen_time)
	Helper.set_timer_properties(shoot_control_timer, true, shoot_control_time)
	
	speed = spawn_speed
	
	# Set the direction to center of viewport
	viewport_size = get_viewport_rect().size
	direction = self.global_position.direction_to(Vector2(viewport_size.x / 2, viewport_size.y / 2))
	
	velocity = speed * direction

	spawn_pos = self.global_position


func _connect_to_signals() -> void:
	screen_notifier.screen_entered.connect(self._on_screen_entered)
	screen_notifier.screen_exited.connect(self._on_screen_exited)
	
	onscreen_timer.timeout.connect(self._on_onscreen_timer_timeout)

	shoot_control_timer.timeout.connect(self._on_shoot_control_timer_timeout)

	shoot_timer.timeout.connect(self._on_shoot_timer_timeout)

	damage_taker_component.damage_taken.connect(self._on_damage_taker_component_damage_taken)
	damage_taker_component.low_health.connect(self._on_damage_taker_component_low_health)
	damage_taker_component.health_depleted.connect(self._on_damage_taker_component_health_depleted)
	pass


################################################
# Decelerate to zero
# Start onscreen timer after entering screen
################################################
func _on_screen_entered() -> void:
	direction = Vector2.ZERO
	onscreen_timer.start()


################################################
# Despawn after leaving screen
################################################
func _on_screen_exited() -> void:
	await get_tree().create_timer(0.5).timeout
	call_deferred("queue_free")


################################################
# When onscreen time elapses, start shooting
################################################
func _on_onscreen_timer_timeout() -> void:
	shoot_control_timer.start()
	shoot_timer.start()


################################################
# Fly offscreen towards opposite corner of spawn after shooting is done
################################################
func _on_shoot_control_timer_timeout() -> void:
	shoot_timer.stop()

	if spawn_pos.x < viewport_size.x / 2:
		if spawn_pos.y < viewport_size.y / 2:
			direction = self.global_position.direction_to(viewport_size)
		elif spawn_pos.y > viewport_size.y / 2:
			direction = self.global_position.direction_to(Vector2(viewport_size.x, 0))
	elif spawn_pos.x > viewport_size.x / 2:
		if spawn_pos.y < viewport_size.y / 2:
			direction = self.global_position.direction_to(Vector2(0, viewport_size.y))
		elif spawn_pos.y > viewport_size.y / 2:
			direction = self.global_position.direction_to(Vector2(0, 0))


################################################
# Rotate the shooting angle after each shot for an arc shooting effect
################################################
func _on_shoot_timer_timeout() -> void:
	shooting_component.default_bullet_angle -= shot_angle_rotation_step_deg


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
	shoot_control_timer.stop()
	shoot_timer.stop()

	speed = speed * 0.25

	SignalsBus.score_increased_event.emit(kill_score)
	
	# Signal to spawn score fragments on death
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	await sprite.animation_finished

	call_deferred("queue_free")
