class_name ScreamerVar2 extends PathFollow2D

@onready var sprite : AnimatedSprite2D = %sprite
@onready var particles : CPUParticles2D = %CPUParticles2D
@onready var hurtbox : Area2D = $hurtbox

@export var kill_score : int = 100
@export var pathfollow_speed : float = 0.1

## TODO: Behaviour
# Variant 2: Fly in a sine wave path from right to left 
# while shooting single projectile straight forward

func _ready() -> void:
	progress_ratio = 0.0


func _process(delta: float) -> void:
	progress_ratio += pathfollow_speed * delta


################################################
# NOTE: Despawn after going offscreen
################################################
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	call_deferred("queue_free")


################################################
# NOTE: Hit by player's bullets, bombs or player
################################################
func _on_hurtbox_area_entered(_area:Area2D) -> void:
	_handle_death()

func _on_hurtbox_body_entered(body:Node2D) -> void:
	if body is PlayerCat:
		if body.is_dead:
			return
		_handle_death()

func _handle_death():
	hurtbox.set_deferred("monitorable", false)
	hurtbox.set_deferred("monitoring", false)

	pathfollow_speed = pathfollow_speed/2

	sprite.play("death")
	particles.emitting = true

	SignalsBus.score_increased_event.emit(kill_score)
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	await sprite.animation_finished

	call_deferred("queue_free")



