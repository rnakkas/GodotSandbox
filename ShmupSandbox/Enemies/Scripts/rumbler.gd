class_name Rumbler extends Area2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var particles : CPUParticles2D = $CPUParticles2D
@onready var onscreen_timer : Timer = $onscreen_timer
@onready var shoot_timer : Timer = $shoot_timer

@export var offscreen_speed : float = 400.0
@export var onscreen_speed: float = 50.0
@export var acceleration : float = 600.0
@export var deceleration : float = 1500.0
@export var kill_score : int = 250
@export var screen_time : float = 10.0
@export var shoot_time : float = 3.3

var direction : Vector2 = Vector2.LEFT
var velocity : Vector2
var activated : bool

## TODO: Spritesheets
## TODO: Shooting logic
## TODO: Getting hit by player, bullets and bombs logic

################################################
# NOTE: Rumbler
# Slow moving area denial enemy
# Flies in from the right
# Slows down to onscreen speed
# Shoots 3 projectiles at the player
# Stays onscreen for about 10 seconds
# Shoots at the player approx 3-4 times when on screen
# After onscreen time elapses, speeds up and flies offscreen to the left
################################################

################################################
# NOTE: Ready
################################################
func _ready() -> void:
	velocity = offscreen_speed * direction
	Helper.set_timer_properties(onscreen_timer, true, screen_time)
	Helper.set_timer_properties(shoot_timer, false, shoot_time)


################################################
# NOTE: Movement logic
################################################
func _physics_process(delta: float) -> void:
	if activated:
		velocity = velocity.move_toward(onscreen_speed * direction, deceleration * delta)
	else:
		velocity = velocity.move_toward(offscreen_speed * direction, acceleration * delta)
	
	global_position += velocity * delta


################################################
# NOTE: Activate after appearing on screen
################################################
func _on_screen_notifier_screen_entered() -> void:
	activated = true
	onscreen_timer.start()
	shoot_timer.start()


################################################
# NOTE: Despawn after going offscreen
################################################
func _on_screen_notifier_screen_exited() -> void:
	call_deferred("queue_free")


################################################
# NOTE: Deactivate after on screen time elapses
################################################
func _on_onscreen_timer_timeout() -> void:
	activated = false
	shoot_timer.stop()


################################################
# NOTE: Shooting logic
################################################
func _on_shoot_timer_timeout() -> void:
	if GameManager.player.is_dead:
		return
	print_debug("shoot at player: ", GameManager.player.global_position)
