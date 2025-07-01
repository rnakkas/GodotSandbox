class_name SoulCarrier extends Area2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var particles : CPUParticles2D = $CPUParticles2D
@onready var move_timer : Timer = $move_timer

@export var base_speed : float = 350.0
@export var acceleration : float = 400.0
@export var max_move_time : float = 0.3
@export var min_move_time : float = 0.1
@export var kill_score : int = 100

var speed : float
var move_time : float
var direction : Vector2 = Vector2.LEFT
var velocity : Vector2

## TODO: Spritesheets

################################################
# NOTE: Soul carrier
# Score item dropper enemy
# Flies in from the right
# After a certain period of time flies back to the right
# If flying to the left, state 1: only drops 2-3 items
# When flying back to right, state 2: drops 4-5 items
################################################

func _ready() -> void:
	speed = base_speed
	move_time = randf_range(min_move_time, max_move_time)
	_set_timer_properties()

func _set_timer_properties() -> void:
	move_timer.one_shot = true
	move_timer.wait_time = move_time


func _physics_process(delta: float) -> void:
	velocity = speed * direction
	global_position += velocity * delta
