class_name Axecutioner extends Node2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var damage_taker_component: DamageTakerComponent = $DamageTakerComponent

@export var kill_score: int = 350

func _ready() -> void:
	_connect_to_signals()


func _connect_to_signals() -> void:
	damage_taker_component.damage_taken.connect(self._on_damage_taker_component_damage_taken)
	damage_taker_component.low_health.connect(self._on_damage_taker_component_low_health)
	damage_taker_component.health_depleted.connect(self._on_damage_taker_component_health_depleted)


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
	# shooting_control_timer.stop()
	# for shoot_timer: Node in tail_shoot_timers_list:
	# 	if shoot_timer is Timer:
	# 		shoot_timer.stop()
	
	# current_state = state.DEATH
	# direction = Vector2.DOWN

	SignalsBus.score_increased_event.emit(kill_score)
	
	# Signal to spawn score fragments on death
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	await sprite.animation_finished

	call_deferred("queue_free")
