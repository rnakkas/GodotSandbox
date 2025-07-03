class_name Rumbler extends Area2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var particles : CPUParticles2D = $CPUParticles2D
@onready var move_timer : Timer = $move_timer
@onready var shoot_timer : Timer = $shoot_timer

@export var base_speed : float = 500.0
@export var acceleration : float = 600.0
@export var deceleration : float = 610.0
@export var kill_score : int = 250
@export var screen_time : float = 3.2
@export var shoot_time : float = 0.8

var speed : float
var move_time : float
var direction : Vector2 = Vector2.LEFT
var velocity : Vector2