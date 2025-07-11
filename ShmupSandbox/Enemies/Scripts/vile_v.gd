class_name VileV extends Node2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var screen_notifier: VisibleOnScreenNotifier2D = $screen_notifier
@onready var onscreen_timer: Timer = $onscreen_timer
@onready var move_timer: Timer = $move_timer
@onready var damage_taker_component: DamageTakerComponent = $DamageTakerComponent
@onready var head_shot_timer: Timer = $head_shot_timer
@onready var body_shot_timer: Timer = $body_shot_timer

@export var offscreen_speed: float = 500.0
@export var fly_off_speed: float = 850.0
@export var onscreen_speed: float = 100.0
@export var acceleration: float = 1300.0
@export var deceleration: float = 1200.0
@export var kill_score: int = 350
@export var screen_time: float = 10.0
@export var move_time: float = 2.7
@export var pre_attack_time: float = 0.8
@export var post_attack_time: float = 1.2
@export var attack_limit: int = 2

var direction: Vector2 = Vector2.LEFT
var velocity: Vector2
var viewport_size: Vector2
var attack_count: int

enum state {
	SPAWN,
	IDLE,
	ATTACK,
	FLY_OFF,
	DEATH
}

var current_state: state

## TODO: Spritesheets and animations

################################################
# ENEMY: Vile V
# High pressure enemy
# Flies in from the right
# Slows down to a stop at the right edge of the screen
# Flies up and down in the y direction
# Shoots continuously at player with targeted shots while flying up and down - does this for 2 cycles
# After onscreen time is elapsed, fly off towards the center of y coordinates on left of screen
# When flying off shoot from the rear muzzles, non targeted spread shots towards Vector2.RIGHT
# Despawn when offscreen
################################################

################################################
# Ready
################################################
func _ready() -> void:
	current_state = state.SPAWN

	_connect_to_signals()
	_set_timer_properties()
	
	viewport_size = get_viewport_rect().size
	velocity = offscreen_speed * direction


func _connect_to_signals() -> void:
	screen_notifier.screen_entered.connect(self._on_screen_entered)
	screen_notifier.screen_exited.connect(self._on_screen_exited)

	onscreen_timer.timeout.connect(self._on_onscreen_timer_timeout)
	
	move_timer.timeout.connect(self._on_move_timer_timeout)
	
	damage_taker_component.damage_taken.connect(self._on_damage_taker_component_damage_taken)
	damage_taker_component.low_health.connect(self._on_damage_taker_component_low_health)
	damage_taker_component.health_depleted.connect(self._on_damage_taker_component_health_depleted)
	

func _set_timer_properties() -> void:
	Helper.set_timer_properties(onscreen_timer, true, screen_time)
	Helper.set_timer_properties(move_timer, true, move_time)


################################################
# Enemy enters the screen:
	# Sits idle for a little bit before moving
	# Start the timers for onscreen and moving
################################################
func _on_screen_entered() -> void:
	current_state = state.IDLE
	onscreen_timer.start()
	move_timer.start()


################################################
# Enemy starts moving up and down:
	# When moving, waits a little bit before actually shooting
################################################
func _on_move_timer_timeout() -> void:
	direction = Vector2.DOWN
	current_state = state.ATTACK

	# Hang around a bit after starting to move and before attacking
	await get_tree().create_timer(pre_attack_time).timeout

	head_shot_timer.start()


################################################
# Enemy's behaviour cycle:
	# Screen time elapses
	# Increases attack cycle counter by 1
	# If attack count is less than limit, start cycle again
	# If attack count more than limit, fly off behaviour
################################################
func _on_onscreen_timer_timeout() -> void:
	attack_count += 1

	# Attack cycle logic
	if attack_count < attack_limit: # Restart cycle
		head_shot_timer.stop()
		deceleration = deceleration * 0.05 # Smoother stopping for up/down movement
		current_state = state.IDLE
		onscreen_timer.start()
		move_timer.start()

	elif attack_count >= attack_limit: # End cycle
		head_shot_timer.stop()

		# Hang around a bit after shooting before flying off
		await get_tree().create_timer(post_attack_time).timeout
		direction = self.global_position.direction_to(Vector2(0, viewport_size.y / 2))
		await get_tree().create_timer(post_attack_time).timeout
		
		# Fly off towards center of left of screen
		current_state = state.FLY_OFF
		body_shot_timer.start()
	
	
################################################
# Despawn on leaving the screen
################################################
func _on_screen_exited() -> void:
	head_shot_timer.stop()
	body_shot_timer.stop()
	call_deferred("queue_free")


################################################
# Process:
	# Clamps position to stay within screen limits
	# Changes direction for up/down movement to stay within limits
################################################
func _process(_delta: float) -> void:
	position = Helper.clamp_movement_to_screen_bounds(viewport_size, position, false, true)
	
	# Switch y direction if hitting upper or lower screen bounds
	direction = Helper.change_direction_on_hitting_screen_bounds(viewport_size, position, direction)


################################################
# Physics process:
	# Velocity logic
################################################
func _physics_process(delta: float) -> void:
	match current_state:
		state.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
		state.ATTACK:
			velocity = velocity.move_toward(onscreen_speed * direction, acceleration * delta)
		state.FLY_OFF:
			velocity = velocity.move_toward(fly_off_speed * direction, acceleration * delta)
		state.DEATH:
			velocity = velocity.move_toward(onscreen_speed * direction, deceleration * delta)
	
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
	head_shot_timer.stop()
	body_shot_timer.stop()
	
	current_state = state.DEATH
	direction = Vector2.DOWN

	SignalsBus.score_increased_event.emit(kill_score)
	
	# Signal to spawn score fragments on death
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	await sprite.animation_finished

	call_deferred("queue_free")
