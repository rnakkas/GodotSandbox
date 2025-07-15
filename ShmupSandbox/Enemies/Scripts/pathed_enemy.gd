class_name PathedEnemy extends PathFollow2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var damage_taker_component: DamageTakerComponent = $DamageTakerComponent
@onready var screen_notifier: VisibleOnScreenNotifier2D = $screen_notifier

@export var kill_score: int = 100
@export var pathfollow_speed: float = 320.0

var shoot_timer: Timer

## TODO: Spritesheets

################################################
# PATHED ENEMIES:
	# Screamer Var 2
	# Crasher Var 1 - doesn't shoot
	# Crasher Var 2 - can shoot
	# Hatter Vars 1 and 2
	# Rider
# Popcorn enemy
# Flies in a set path
# Shooting dependent on shooting component
################################################

################################################
# Ready
################################################
func _ready() -> void:
	shoot_timer = get_node_or_null("shoot_timer")
	_connect_to_signals()
	progress_ratio = 1.0 # Start at the right side of screen


func _connect_to_signals() -> void:
	screen_notifier.screen_entered.connect(self._on_screen_entered)
	screen_notifier.screen_exited.connect(self._on_screen_exited)
	damage_taker_component.damage_taken.connect(self._on_damage_taker_component_damage_taken)
	damage_taker_component.health_depleted.connect(self._on_damage_taker_component_health_depleted)


################################################
# Physics process for moving in path
################################################
func _physics_process(delta: float) -> void:
	progress -= pathfollow_speed * delta


################################################
# Start shooting timer when onscreen
################################################
func _on_screen_entered() -> void:
	if shoot_timer != null:
		shoot_timer.start()


################################################
# Despawn after going offscreen
################################################
func _on_screen_exited() -> void:
	if shoot_timer != null:
		shoot_timer.stop()
	call_deferred("queue_free")


################################################
# Getting hit by player attacks logic:
	# Signal connections from damage taker component
################################################
func _on_damage_taker_component_damage_taken() -> void:
	SignalsBus.score_increased_event.emit(GameManager.attack_hit_score)

func _on_damage_taker_component_health_depleted() -> void:
	pathfollow_speed = pathfollow_speed / 2

	sprite.play("death")
	particles.emitting = true

	SignalsBus.score_increased_event.emit(kill_score)
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	await sprite.animation_finished

	call_deferred("queue_free")
