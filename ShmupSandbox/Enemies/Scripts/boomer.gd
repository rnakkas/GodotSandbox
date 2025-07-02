class_name Boomer extends Area2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var particles : CPUParticles2D = $CPUParticles2D
@onready var tracker_timer : Timer = $tracker_timer
@onready var chase_timer : Timer = $chase_timer
@onready var screen_notifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

@export var speed : float = 250.0
@export var tracking_time : float = 0.13
@export var chase_time : float = 2.0
@export var kill_score : int = 100

var direction : Vector2 = Vector2.LEFT


################################################
# NOTE: Ready
################################################
func _ready() -> void:
	_get_direction_to_player()

	Helper.set_timer_properties(tracker_timer, false, tracking_time)
	Helper.set_timer_properties(chase_timer, true, chase_time)

	tracker_timer.start()
	chase_timer.start()

func _get_direction_to_player() -> void:
	if GameManager.player == null:
		return
	if GameManager.player.is_dead:
		return
	direction = self.global_position.direction_to(GameManager.player.global_position).normalized()


################################################
# NOTE: Process, flip sprite based on movement direction 
################################################
func _process(_delta: float) -> void:
	if direction.x < 0:
		sprite.flip_h = false
	elif direction.x > 0:
		sprite.flip_h = true


################################################
# NOTE: Physics process, movement
################################################
func _physics_process(delta: float) -> void:
	global_position += speed * delta * direction


################################################
# NOTE: Despawn when offscreen
################################################
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	call_deferred("queue_free")


################################################
# NOTE: Player tracking logic
################################################
func _on_tracker_timer_timeout() -> void:
	_get_direction_to_player()


################################################
# NOTE: Stop tracking/chasing player
################################################
func _on_chase_timer_timeout() -> void:
	tracker_timer.stop()


################################################
# NOTE: Hit by player's bullets/bombs or player
################################################
func _on_area_entered(_area: Area2D) -> void:
	_handle_death()

func _on_body_entered(body:Node2D) -> void:
	if body is PlayerCat:
		if body.is_dead:
			return
		_handle_death()

func _handle_death() -> void:
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)

	tracker_timer.stop()
	chase_timer.stop()
	
	speed = speed/2

	sprite.play("explode")
	particles.emitting = true

	SignalsBus.score_increased_event.emit(kill_score)
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	await sprite.animation_finished
	call_deferred("queue_free")
