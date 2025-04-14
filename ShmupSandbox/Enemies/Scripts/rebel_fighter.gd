class_name RebelFighter extends Area2D

@export var hp : int
@export var speed : float
@export var hit_score : int = 50
@export var kill_score : int = 100

@onready var enemy_sprite : AnimatedSprite2D = $body
@onready var particles : CPUParticles2D = $CPUParticles2D



func _physics_process(delta: float) -> void:
	global_position.x -= speed * delta

func _process(_delta: float) -> void:
	_handle_dying()

func _handle_dying() -> void:
	if hp <= 0:
		_deactivate_self()
		enemy_sprite.play("death")
		particles.emitting = true
		await enemy_sprite.animation_finished
		queue_free()

func _deactivate_self() -> void:
	speed = 0.0
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

## Hit by player's bullets
func _on_area_entered(_area: Area2D) -> void:
	hp -= 1
	SignalsBus.score_when_hit(hit_score)
	if hp <= 0:
		SignalsBus.score_when_killed(kill_score)
