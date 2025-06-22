class_name Boomer extends Area2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var particles : CPUParticles2D = $CPUParticles2D
@onready var tracker_timer : Timer = $tracker_timer
@onready var chase_timer : Timer = $chase_timer
@onready var screen_notifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

@export var speed : float = 250.0
@export var tracking_time : float = 0.13
@export var chase_time : float = 2.5
@export var kill_score : int = 100

var player : CharacterBody2D
var direction : Vector2 = Vector2.LEFT

## TODO:
	# Movement:
	# - when spawns, get player's position
	# - home in on player's position
	# - every 0.5 seconds, get player's updated position
	# - after chase time elapses, stop tracking and fly offscreen

func _ready() -> void:
	player = get_tree().get_first_node_in_group(GameManager.player_group)
	direction = self.global_position.direction_to(player.global_position)

	_set_tracker_timer_properties()
	_set_chase_timer_properties()

	tracker_timer.start()
	chase_timer.start()


func _set_tracker_timer_properties() -> void:
	tracker_timer.one_shot = false
	tracker_timer.wait_time = tracking_time

func _set_chase_timer_properties() -> void:
	chase_timer.one_shot = true
	chase_timer.wait_time = chase_time


func _physics_process(delta: float) -> void:
	global_position += speed * delta * direction


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	call_deferred("queue_free")


func _on_tracker_timer_timeout() -> void:
	direction = self.global_position.direction_to(player.global_position)


func _on_chase_timer_timeout() -> void:
	tracker_timer.stop()


func _on_area_entered(area: Area2D) -> void:
	if area is PlayerBullet || area is BombFuzz:
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)

		tracker_timer.stop()
		chase_timer.stop()
		
		speed = speed/2

		sprite.play("explode")
		particles.emitting = true

		SignalsBus.score_increased_event.emit(kill_score)

		await sprite.animation_finished
		call_deferred("queue_free")
