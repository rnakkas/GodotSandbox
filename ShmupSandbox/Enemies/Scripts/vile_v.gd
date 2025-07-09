class_name VileV extends Area2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var screen_notifier: VisibleOnScreenNotifier2D = $screen_notifier
@onready var onscreen_timer: Timer = $onscreen_timer
@onready var move_timer: Timer = $move_timer
@onready var overlord_shoot_timer: Timer = $overlord_shoot_timer
@onready var shoot_timers_container: Node = $shoot_timers_container
@onready var tail_shoot_timers_container: Node = $tail_shoot_timers_container

@export var offscreen_speed: float = 500.0
@export var fly_off_speed: float = 850.0
@export var onscreen_speed: float = 75.0
@export var acceleration: float = 1300.0
@export var deceleration: float = 1200.0
@export var kill_score: int = 350
@export var screen_time: float = 10.0
@export var move_time: float = 2.7
@export var overlord_shoot_time: float = 0.32

var direction: Vector2 = Vector2.LEFT
var velocity: Vector2
var shoot_timers_list: Array[Node] = []
var tail_shoot_timers_list: Array[Node] = []
var viewport_size: Vector2
var can_attack: bool
var current_muzzle: int = 0

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
	# - comes on screen - done
	# - slows to a stop - done
	# - when first shooting timer timesout, shooting starts - done
	# - when shooting starts, moves up and down - done
	# - when onscreen time elapses, fly towards left - done
	# - this starts the tail shooting timers - done
	# - set the direction of shots for tail shots- done
	# - getting hurt and dying logic

################################################
# NOTE: Vile V
# High pressure enemy
# Flies in from the right
# Slows down to a stop at the right edge of the screen
# Flies up and down in the y direction
# Shoots continuously at player with targeted shots while flying up and down
# After onscreen time is elapsed, fly off towards the center of y coordinates on left of screen
# When flying off shoot from the rear muzzles, non targeted spread shots towards Vector2.RIGHT
# Despawn when offscreen
################################################

func _ready() -> void:
	current_state = state.SPAWN

	shoot_timers_list = shoot_timers_container.get_children()
	shoot_timers_list.sort()

	tail_shoot_timers_list = tail_shoot_timers_container.get_children()
	tail_shoot_timers_list.sort()

	_connect_to_signals()
	_set_timer_properties()
	
	viewport_size = get_viewport_rect().size

	velocity = offscreen_speed * direction


func _connect_to_signals() -> void:
	screen_notifier.screen_entered.connect(self._on_screen_entered)
	screen_notifier.screen_exited.connect(self._on_screen_exited)
	onscreen_timer.timeout.connect(self._on_onscreen_timer_timeout)
	move_timer.timeout.connect(self._on_move_timer_timeout)
	overlord_shoot_timer.timeout.connect(self._on_overlord_shoot_timer_timeout)


func _set_timer_properties() -> void:
	Helper.set_timer_properties(onscreen_timer, true, screen_time)
	Helper.set_timer_properties(move_timer, true, move_time)
	Helper.set_timer_properties(overlord_shoot_timer, false, overlord_shoot_time)


func _on_screen_entered() -> void:
	current_state = state.IDLE
	onscreen_timer.start()
	move_timer.start()


func _on_move_timer_timeout() -> void:
	direction = Vector2.DOWN
	current_state = state.ATTACK

	# Hang around a bit after shooting before attacking
	await get_tree().create_timer(2.5).timeout

	overlord_shoot_timer.start()


func _on_onscreen_timer_timeout() -> void:
	overlord_shoot_timer.stop()
	
	# Hang around a bit after shooting before flying off
	await get_tree().create_timer(2.5).timeout
	
	# Fly off towards center of left of screen
	direction = self.global_position.direction_to(Vector2(0, viewport_size.y/2))
	current_state = state.FLY_OFF

	for shoot_timer: Node in tail_shoot_timers_list:
		if shoot_timer is Timer:
			shoot_timer.start()
	

func _on_overlord_shoot_timer_timeout() -> void:
	for i: int in range(shoot_timers_list.size()):
		if shoot_timers_list[i] is Timer && i == current_muzzle:
			shoot_timers_list[i].start()
			current_muzzle = (i + 1) % shoot_timers_list.size() # To wrap around to the first shot timer
			break


func _on_screen_exited() -> void:
	for shoot_timer: Node in tail_shoot_timers_list:
		if shoot_timer is Timer:
			shoot_timer.stop()
	
	call_deferred("queue_free")



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
