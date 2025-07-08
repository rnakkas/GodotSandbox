class_name VileV extends Area2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var screen_notifier: VisibleOnScreenNotifier2D = $screen_notifier

@onready var onscreen_timer: Timer = $onscreen_timer
@onready var shoot_timer: Timer = $shoot_timer

@export var offscreen_speed: float = 700.0
@export var onscreen_speed: float = 100.0
@export var acceleration: float = 900.0
@export var deceleration: float = 1600.0
@export var kill_score: int = 350
@export var screen_time: float = 3.0

var direction: Vector2 = Vector2.LEFT
var velocity: Vector2
var onscreen: bool
var attacking: bool

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
	_connect_to_signals()
	velocity = offscreen_speed * direction
	Helper.set_timer_properties(onscreen_timer, true, screen_time)


func _connect_to_signals() -> void:
	screen_notifier.screen_entered.connect(self._on_screen_entered)
	screen_notifier.screen_exited.connect(self._on_screen_exited)
	onscreen_timer.timeout.connect(self._on_onscreen_timer_timeout)


func _on_screen_entered() -> void:
	onscreen = true
	onscreen_timer.start()
	# direction = Vector2.DOWN


func _on_screen_exited() -> void:
	call_deferred("queue_free")


func _on_onscreen_timer_timeout() -> void:
	direction = Vector2.LEFT
	onscreen = false


func _physics_process(delta: float) -> void:
	if onscreen:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	global_position += velocity * delta