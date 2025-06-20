class_name Doomboard extends Area2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var particles : CPUParticles2D = $CPUParticles2D
@onready var dot_timer : Timer = $dot_timer

const offscreen_speed : float = 200.0
const onscreen_speed : float = 45.0
const dot_time : float = 0.3

@export var speed : float = offscreen_speed
@export var hp : int = 30
@export var hit_score : int = 10
@export var kill_score : int = 250
@export var dot_score : int = 2

var damage_from_bomb: int
var can_die : bool

## TODO:
	#### Change doomboard to Node2D type, add a hurtbox component to handle hurt/death logic, so i can reuse for other enemies
	# - spawn offscreen right side - TODO: awaiting spawn scheduler work
	# - when spawned offscreen, move at a faster speed until on screen - DONE
	# - when offscreen cannot be damaged, disable collisions - DONE
	# - when on screen, enable collisions - DONE
	# - when onscreen, move at a slower speed towards the left - DONE
	# - timer: on timeout move towards center of player's y coordinates
	# - when offscreen right, despawn - DONE
	# - when hit, take damage
	# - if below 50% health, play damaged animation instead of idle
	# - if health depleted, dies and play death animation
	# - on death, signal to spawn powerup at death position



func _ready() -> void:
	# Disable collisions when spawned, will be enabled when it enters screen
	# To prevent being prematurely killed
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)

	_set_timer_properties()

func _set_timer_properties() -> void:
	dot_timer.one_shot = false
	dot_timer.wait_time = dot_time


func _process(_delta: float) -> void:
	_handle_death()

func _handle_death() -> void:
	if can_die:
		can_die = false

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

		call_deferred("queue_free")


func _physics_process(delta: float) -> void:
	global_position += speed * delta * Vector2.LEFT


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	speed = onscreen_speed

	# Enable collisions when on screen, to be able to be hurt/killed
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Despawn when it leaves screen
	call_deferred("queue_free")

# Hit by player's bullets or bombs 
func _on_area_entered(area:Area2D) -> void:
	if area is PlayerBullet: 
		hp -= area.damage
		SignalsBus.score_increased_event.emit(hit_score)
	elif area is BombFuzz:
		damage_from_bomb = area.damage
		dot_timer.start()
	
	if hp <= 0:
		can_die = true


# When bomb despawns
func _on_area_exited(area:Area2D) -> void:
	if area is BombFuzz:
		dot_timer.stop()


# When damage over time ticks
func _on_dot_timer_timeout() -> void:
	hp -= damage_from_bomb
	SignalsBus.score_increased_event.emit(dot_score)

	if hp <= 0:
		can_die = true
		dot_timer.stop()


# When player flies into doomboard
func _on_body_entered(body:Node2D) -> void:
	if body is PlayerCat:
		hp -= body.damage
		SignalsBus.score_increased_event.emit(hit_score)
