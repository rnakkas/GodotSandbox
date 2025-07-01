class_name SoulCarrier extends Area2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var particles : CPUParticles2D = $CPUParticles2D
@onready var move_timer : Timer = $move_timer

@export var base_speed : float = 420.0
@export var acceleration : float = 400.0
@export var max_move_time : float = 0.8
@export var min_move_time : float = 0.5
@export var kill_score : int = 100


enum drop_state {
	STANDARD,
	HIGH
}

var speed : float
var move_time : float
var direction : Vector2 = Vector2.LEFT
var velocity : Vector2
var current_state = drop_state.STANDARD

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
	if direction == Vector2.RIGHT:
		velocity = velocity.move_toward(speed * direction, acceleration * delta)
	else:
		velocity = speed * direction
	
	global_position += velocity * delta


func _on_onscreen_notifier_screen_entered() -> void:
	move_timer.start()


func _on_offscreen_notifier_screen_exited() -> void:
	call_deferred("queue_free")


func _on_move_timer_timeout() -> void:
	direction = Vector2.RIGHT
	await get_tree().create_timer(1.2).timeout # Will also need an animation here
	current_state = drop_state.HIGH


################################################
# NOTE: Hit by player's bullets, bombs or player
################################################
func _on_area_entered(_area:Area2D) -> void:
	_handle_death()

func _on_body_entered(body:Node2D) -> void:
	if body is PlayerCat:
		if body.is_dead:
			return
		_handle_death()

func _handle_death():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)

	speed = speed/4

	sprite.play("death")
	particles.emitting = true

	SignalsBus.score_increased_event.emit(kill_score)
	SignalsBus.spawn_score_item_event.emit(self.global_position)

	match current_state:
		drop_state.STANDARD:
			print_debug("standard drop")
		drop_state.HIGH:
			print_debug("high drop")

	await sprite.animation_finished

	call_deferred("queue_free")
