class_name ScreamerVar2 extends Area2D

@onready var sprite : AnimatedSprite2D = %sprite
@onready var particles : CPUParticles2D = %CPUParticles2D

@export var kill_score : int = 100

## TODO: Behaviour
# Variant 2: Fly in a sine wave path from right to left 
# while shooting single projectile straight forward