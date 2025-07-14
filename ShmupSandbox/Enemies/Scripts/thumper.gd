class_name Thumper extends Node2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var damage_taker_component: DamageTakerComponent = $DamageTakerComponent
@onready var screen_notifier_right: VisibleOnScreenNotifier2D = $screen_notifier_right
@onready var screen_notifier_left: VisibleOnScreenNotifier2D = $screen_notifier_left
@onready var shoot_timer: Timer = $shoot_timer
@onready var shooting_component: EnemyShootingComponent = $EnemyShootingComponent

@export var kill_score: int = 200
@export var speed: float = 175.0

var direction: Vector2 = Vector2.LEFT

## TODO: Spritesheets and animations

################################################
# ENEMY: Thumper
# Mid level enemy
# Flies in from left of screen
# When on screen, shoots either in +y or -y direction
# Shoot in a spread of 4 bullets
# Despawn when offscreen
################################################

################################################
# Ready
################################################
func _ready() -> void:
	_connect_to_signals()
	_set_shooting_direction()


func _connect_to_signals() -> void:
	screen_notifier_left.screen_entered.connect(self._on_screen_left_entered)
	screen_notifier_left.screen_exited.connect(self._on_screen_left_exited)
	screen_notifier_right.screen_exited.connect(self._on_screen_right_exited)
	
	damage_taker_component.damage_taken.connect(self._on_damage_taker_component_damage_taken)
	damage_taker_component.low_health.connect(self._on_damage_taker_component_low_health)
	damage_taker_component.health_depleted.connect(self._on_damage_taker_component_health_depleted)


func _set_shooting_direction() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	
	# Shoot downwards if above y centerline
	# Shoot upwards if below y centerline
	if self.global_position.y <= viewport_size.y / 2:
		shooting_component.bullet_direction.y = 1.0
	elif self.global_position.y > viewport_size.y / 2:
		shooting_component.bullet_direction.y = -1.0


################################################
# Velocity logic
################################################
func _physics_process(delta: float) -> void:
	global_position += speed * direction * delta


################################################
# Start shooting timer after coming onscreen
################################################
func _on_screen_left_entered() -> void:
	shoot_timer.start()


################################################
# Stop shooting timer when just about to go offscreen
################################################
func _on_screen_left_exited() -> void:
	shoot_timer.stop()


################################################
# Despawn after leaving screen
################################################
func _on_screen_right_exited() -> void:
	call_deferred("queue_free")


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

	speed = speed * 0.5

	SignalsBus.score_increased_event.emit(kill_score)
	
	# Signal to spawn score fragments on death
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	await sprite.animation_finished

	call_deferred("queue_free")
