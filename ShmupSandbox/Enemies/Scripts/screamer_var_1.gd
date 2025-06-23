class_name ScreamerVar1 extends Area2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var particles : CPUParticles2D = $CPUParticles2D

@export var speed : float = 210.0
@export var kill_score : int = 100

## TODO: Behavior
# Variant 1: Fly into screen from top, bottom or right, 
# shoot a single projectile at player position, 
# then fly in a straight line back to the right to off screen