class_name VileV extends Area2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var screen_notifier: VisibleOnScreenNotifier2D = $screen_notifier
@onready var onscreen_timer: Timer = $onscreen_timer
@onready var move_timer: Timer = $move_timer
@onready var shoot_timers_container: Node2D = $shoot_timers_container

@export var offscreen_speed: float = 600.0
@export var fly_off_speed: float = 850.0
@export var onscreen_speed: float = 150.0
@export var acceleration: float = 1300.0
@export var deceleration: float = 1200.0
@export var kill_score: int = 350
@export var screen_time: float = 10.0
@export var move_time: float = 1.2

var direction: Vector2 = Vector2.LEFT
var velocity: Vector2
var shoot_timers_list: Array[Node] = []
var viewport_size: Vector2

enum state {
	SPAWN,
	IDLE,
	ATTACK,
	FLY_OFF
}

var current_state: state

## TODO: Spritesheets

## TODO: Shooting logic
## TODO: Movement logic
	# - comes on screen
	# - slows to a stop
	# - when first shooting timer timesout, shooting starts
	# - when shooting starts, moves up and down
	# - when onscreen time elapses, fly towards left at player y pos
	# - this starts the tail shooting timers

################################################
# NOTE: Vile V
# High pressure enemy
# Flies in from the right
# Slows down to a stop at the right edge of the screen
# Flies up and down in the y direction
# Shoots continuously at player with targeted shots while flying up and down
# After onscreen time is elapsed, fly off towards the right at player's y position
# When flying off shoot from the rear muzzles, non targeted spread shots towards Vector2.RIGHT
# Despawn when offscreen
################################################

func _ready() -> void:
	current_state = state.SPAWN

	shoot_timers_list = shoot_timers_container.get_children()
	shoot_timers_list.sort()

	_connect_to_signals()
	
	velocity = offscreen_speed * direction

	Helper.set_timer_properties(onscreen_timer, true, screen_time)
	Helper.set_timer_properties(move_timer, true, move_time)

	viewport_size = get_viewport_rect().size


func _connect_to_signals() -> void:
	screen_notifier.screen_entered.connect(self._on_screen_entered)
	screen_notifier.screen_exited.connect(self._on_screen_exited)
	onscreen_timer.timeout.connect(self._on_onscreen_timer_timeout)
	move_timer.timeout.connect(self._on_move_timer_timeout)


func _on_screen_entered() -> void:
	current_state = state.IDLE
	onscreen_timer.start()
	move_timer.start()


func _on_screen_exited() -> void:
	call_deferred("queue_free")


func _on_onscreen_timer_timeout() -> void:
	direction = Vector2.LEFT
	current_state = state.FLY_OFF


func _on_move_timer_timeout() -> void:
	direction = Vector2.DOWN
	current_state = state.ATTACK


func _process(_delta: float) -> void:
	position = Helper.clamp_movement_to_screen_bounds(viewport_size, position, false, true)
	
	# Switch y direction if hitting upper or lower screen bounds
	direction = Helper.change_direction_on_hitting_screen_bounds(viewport_size, position, direction)


func _physics_process(delta: float) -> void:
	match current_state:
		state.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
		state.ATTACK:
			velocity = velocity.move_toward(onscreen_speed * direction, acceleration * delta)
		state.FLY_OFF:
			velocity = velocity.move_toward(fly_off_speed * direction, acceleration * delta)
	
	global_position += velocity * delta
