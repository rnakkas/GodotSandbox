class_name VileV extends Area2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var onscreen_timer: Timer = $onscreen_timer
@onready var shoot_timer: Timer = $shoot_timer

@export var offscreen_speed: float = 400.0
@export var onscreen_speed: float = 100.0
@export var acceleration: float = 600.0
@export var deceleration: float = 1500.0
@export var kill_score: int = 350
@export var screen_time: float = 10.0

var direction: Vector2 = Vector2.LEFT
var velocity: Vector2
var activated: bool

## TODO: Spritesheets
## TODO: Shooting logic
## TODO: Movement logic

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