class_name Boomer extends Node2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var tracker_timer: Timer = $tracker_timer
@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var damage_taker_component: DamageTakerComponent = $DamageTakerComponent

@export var speed: float = 350.0
@export var tracking_time: float = 0.13
@export var chase_time: float = 2.0
@export var kill_score: int = 100

var direction: Vector2 = Vector2.LEFT


################################################
# Ready
################################################
func _ready() -> void:
	_connect_to_signals()
	_get_direction_to_player()
	Helper.set_timer_properties(tracker_timer, false, tracking_time)
	tracker_timer.start()

func _connect_to_signals() -> void:
	screen_notifier.screen_exited.connect(self._on_screen_notifier_screen_exited)
	tracker_timer.timeout.connect(self._on_tracker_timer_timeout)
	damage_taker_component.damage_taken.connect(self._on_damage_taker_component_damage_taken)
	damage_taker_component.health_depleted.connect(self._on_damage_taker_component_health_depleted)

func _get_direction_to_player() -> void:
	if GameManager.player == null:
		return
	if GameManager.player.is_dead:
		return
	direction = self.global_position.direction_to(GameManager.player.global_position).normalized()


################################################
# Process, flip sprite based on movement direction 
################################################
func _process(_delta: float) -> void:
	if direction.x < 0:
		sprite.flip_h = false
	elif direction.x > 0:
		sprite.flip_h = true


################################################
# Physics process, movement
################################################
func _physics_process(delta: float) -> void:
	global_position += speed * delta * direction


################################################
# Despawn when offscreen
################################################
func _on_screen_notifier_screen_exited() -> void:
	await get_tree().create_timer(0.5).timeout
	call_deferred("queue_free")


################################################
# Player tracking logic
################################################
func _on_tracker_timer_timeout() -> void:
	_get_direction_to_player()


################################################
# Getting hit by player attacks logic:
	# Signal connections from damage taker component
################################################
func _on_damage_taker_component_damage_taken() -> void:
	SignalsBus.score_increased_event.emit(GameManager.attack_hit_score)

func _on_damage_taker_component_health_depleted() -> void:
	tracker_timer.stop()
	
	speed = speed / 2

	sprite.play("death")
	particles.emitting = true

	SignalsBus.score_increased_event.emit(kill_score)
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	await sprite.animation_finished
	call_deferred("queue_free")
