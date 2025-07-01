extends Area2D
class_name ScreamerVar3

@onready var sprite : AnimatedSprite2D = $sprite
@onready var particles : CPUParticles2D = $CPUParticles2D

@export var base_speed : float = 500.0
@export var acceleration : float = 600.0
@export var kill_score : int = 100
@export var shoot_time : float = 0.8

