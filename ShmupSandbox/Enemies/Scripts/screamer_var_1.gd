class_name ScreamerVar1 extends Node2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var particles : CPUParticles2D = $CPUParticles2D
@onready var move_timer : Timer = $move_timer
@onready var shoot_timer : Timer = $shoot_timer

@export var base_speed : float = 500.0
@export var acceleration : float = 600.0
@export var deceleration : float = 610.0
@export var kill_score : int = 100
@export var max_move_time : float = 0.3
@export var min_move_time : float = 0.1
@export var shoot_time : float = 0.8
@export var shot_limit : int = 3

var speed : float
var move_time : float
var direction : Vector2 = Vector2.LEFT
var velocity : Vector2
var shot_count : int

## TODO: Spritesheets

################################################
# NOTE: Screamer Variant 1
# Popcorn enemy
# Flies in from the right
# Stops
# Shoots 3 times at player
# Flies off back to the right
################################################

################################################
# NOTE: Ready
################################################
func _ready() -> void:
	speed = base_speed
	move_time = randf_range(min_move_time, max_move_time)
	Helper.set_timer_properties(move_timer, true, move_time)
	Helper.set_timer_properties(shoot_timer, false, shoot_time)


################################################
# NOTE: Physics process for movement
################################################
func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	global_position += velocity * delta


################################################
# NOTE: Start timer for moevement stop when onscreen
################################################
func _on_onscreen_notifier_screen_entered() -> void:
	move_timer.start()


################################################
# NOTE: When moving stops, start counter to start shooting
################################################
func _on_move_timer_timeout() -> void:
	direction = Vector2.ZERO
	shoot_timer.start()



################################################
# NOTE: Shooting logic
################################################
func _on_shoot_timer_timeout() -> void:
	shot_count += 1

	# Stop shooting and fly off if shot limit is reached or if player is dead
	if shot_count >= shot_limit || GameManager.player.is_dead:
		shoot_timer.stop()
		var viewport_size : Vector2 = get_viewport_rect().size
		var dir_y : float = randf_range(0, viewport_size.y)
		direction = self.global_position.direction_to(Vector2(viewport_size.x, dir_y))
	
	var player_position = self.global_position.direction_to(GameManager.player.global_position).normalized()
	var bullet : ScreamerBullet = SceneManager.screamer_bullet_scene.instantiate()
	var bullets_list : Array[Area2D]

	bullet.global_position = self.global_position
	bullet.direction = player_position
	bullets_list.append(bullet)
	SignalsBus.enemy_shooting_event.emit(bullets_list)


################################################
# NOTE: Despawn after going offscreen
################################################
func _on_offscreen_notifier_screen_exited() -> void:
	call_deferred("queue_free")


################################################
# NOTE: Getting hit by player attacks logic:
	# Signal connections from damage taker component
################################################
func _on_damage_taker_component_health_depleted() -> void:
	shoot_timer.stop()

	speed = speed/2

	sprite.play("death")
	particles.emitting = true

	SignalsBus.score_increased_event.emit(kill_score)
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	await sprite.animation_finished

	call_deferred("queue_free")
