class_name Rimshot extends Node2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var damage_taker_component: DamageTakerComponent = $DamageTakerComponent
@onready var screen_notifier: VisibleOnScreenNotifier2D = $screen_notifier

@export var speed: float = 500.0
@export var acceleration: float = 1000.0
@export var deceleration: float = 800.0

var direction: Vector2
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

func _ready() -> void:
	_connect_to_signals()
	velocity = speed * direction


func _connect_to_signals() -> void:
	screen_notifier.screen_entered.connect(self._on_screen_entered)
	screen_notifier.screen_exited.connect(self._on_screen_exited)


func _on_screen_entered() -> void:
	## decelerate to a stop
	pass


func _on_screen_exited() -> void:
	await get_tree().create_timer(0.5).timeout
	call_deferred("queue_free")


# func _physics_process(delta: float) -> void:
# 	pass