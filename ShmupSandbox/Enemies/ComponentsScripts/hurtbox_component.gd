class_name HurtboxComponent extends Area2D

@export var hp : int = 30
@export var hit_score : int = 10
@export var kill_score : int = 250
@export var dot_timer : Timer
@export var dot_tick_time : float = 0.3
@export var sprite : AnimatedSprite2D
@export var particles : CPUParticles2D

var damage_from_bomb: int

signal health_depleted()

## TODO: debug the issues

func _ready() -> void:
	# Disable collisions when spawned, will be enabled when it enters screen
	# To prevent being prematurely killed
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)

	_set_timer_properties()
	

func _set_timer_properties() -> void:
	dot_timer.one_shot = false
	dot_timer.wait_time = dot_tick_time


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	# Enable collisions when on screen, to be able to be hurt/killed
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)


func _on_area_entered(area:Area2D) -> void:
	if area is PlayerBullet: 
		hp -= area.damage
		SignalsBus.score_increased_event.emit(hit_score)
	elif area is BombFuzz:
		damage_from_bomb = area.damage
		dot_timer.start()

	if hp <= 0:
		_handle_death()


func _on_dot_timer_timeout() -> void:
	hp -= damage_from_bomb
	SignalsBus.score_increased_event.emit(hit_score)

	if hp <= 0:
		dot_timer.stop()
		_handle_death()


func _on_area_exited(area:Area2D) -> void:
	if area is BombFuzz:
		dot_timer.stop()


func _on_body_entered(body:Node2D) -> void:
	if body is PlayerCat:
		hp -= body.damage
		SignalsBus.score_increased_event.emit(hit_score)
	
	if hp <= 0:
		_handle_death()


func _handle_death() -> void:
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	
	sprite.play("death")
	particles.emitting = true
	await sprite.animation_finished
	
	SignalsBus.score_increased_event.emit(kill_score)

	# Signal to spawn powerup
	SignalsBus.spawn_powerup_event.emit(self.global_position)
	
	# Signal to spawn score fragments on death
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	health_depleted.emit()
