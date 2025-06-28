class_name Skulljack extends Area2D

@export var speed : float = 500.0
@export var kill_score : int = 50

@onready var enemy_sprite : AnimatedSprite2D = $animated_sprite
@onready var particles : CPUParticles2D = $CPUParticles2D


func _ready() -> void:
	speed = randf_range(speed, speed*1.5)


func _physics_process(delta: float) -> void:
	global_position.x -= speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


## Hit by player's bullets or bombs
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

	speed = speed / 1.7

	enemy_sprite.play("death")
	particles.emitting = true

	SignalsBus.score_increased_event.emit(kill_score)
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	await enemy_sprite.animation_finished

	call_deferred("queue_free")
	


