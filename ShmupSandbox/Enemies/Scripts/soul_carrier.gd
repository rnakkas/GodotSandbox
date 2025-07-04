class_name SoulCarrier extends Node2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var particles : CPUParticles2D = $CPUParticles2D
@onready var move_timer : Timer = $move_timer

@export var base_speed : float = 420.0
@export var acceleration : float = 400.0
@export var max_move_time : float = 0.8
@export var min_move_time : float = 0.5
@export var kill_score : int = 100
@export var standard_drop : int = 1
@export var high_drop : int = 3

var speed : float
var move_time : float
var direction : Vector2 = Vector2.LEFT
var velocity : Vector2
var current_drop : int
var is_dead : bool

## TODO: Spritesheets

################################################
# NOTE: Soul carrier
# Score item dropper enemy
# Flies in from the right
# After a certain period of time flies back to the right
# If flying to the left, state 1: only drops 1 item
# When flying back to right, state 2: drops 3 items
################################################

################################################
# NOTE: Ready
################################################
func _ready() -> void:
	speed = base_speed
	move_time = randf_range(min_move_time, max_move_time)
	current_drop = standard_drop
	Helper.set_timer_properties(move_timer, true, move_time)


################################################
# NOTE: Movement logic
################################################
func _physics_process(delta: float) -> void:
	if direction == Vector2.RIGHT:
		velocity = velocity.move_toward(speed * direction, acceleration * delta)
	else:
		velocity = speed * direction
	
	global_position += velocity * delta


################################################
# NOTE: Start timer for flying back to right
################################################
func _on_onscreen_notifier_screen_entered() -> void:
	move_timer.start()


################################################
# NOTE: Despawn after leaving screen
################################################
func _on_offscreen_notifier_screen_exited() -> void:
	call_deferred("queue_free")


################################################
# NOTE: Set flying back direction and drop state change
################################################
func _on_move_timer_timeout() -> void:
	direction = Vector2.RIGHT
	await get_tree().create_timer(1.2).timeout # Will also need an animation here
	current_drop = high_drop


################################################
# NOTE: Getting hit by player attacks logic:
	# Signal connections from damage taker component
################################################
func _on_damage_taker_component_health_depleted() -> void:
	speed = speed/4

	sprite.play("death")
	particles.emitting = true

	SignalsBus.score_increased_event.emit(kill_score)
	
	# Spawn score items based on current drop state, either standard or high
	for i : int in range(current_drop):
		SignalsBus.spawn_score_item_event.emit(self.global_position)

	await sprite.animation_finished

	call_deferred("queue_free")
