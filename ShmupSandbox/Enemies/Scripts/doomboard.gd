class_name Doomboard extends Area2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var particles : CPUParticles2D = $CPUParticles2D
@onready var dot_timer : Timer = $dot_timer
@onready var movement_timer : Timer = $movement_timer

const offscreen_speed : float = 200.0
const onscreen_speed : float = 45.0
const dot_time : float = 0.3
const move_time : float = 6.0

@export var speed : float = offscreen_speed
@export var max_hp : int = 30
@export var hit_score : int = 10
@export var kill_score : int = 250
@export var dot_score : int = 2

var hp : int = max_hp
var low_hp_threshold : int = round((max_hp as float)/3)
var damage_from_bomb: int
var can_die : bool
var viewport_size : Vector2
var direction : Vector2 = Vector2.LEFT


################################################
# NOTE: Ready
################################################
func _ready() -> void:
	viewport_size = get_viewport_rect().size

	# Disable collisions when spawned, will be enabled when it enters screen
	# To prevent being prematurely killed
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)

	_set_dot_timer_properties()
	_set_movement_timer_properties()

func _set_dot_timer_properties() -> void:
	dot_timer.one_shot = false
	dot_timer.wait_time = dot_time

func _set_movement_timer_properties() -> void:
	movement_timer.one_shot = true
	movement_timer.wait_time = move_time


################################################
# NOTE: Physics process, movement
################################################
func _physics_process(delta: float) -> void:
	global_position += speed * delta * direction


################################################
# NOTE: Signal connection, move slower when on screen, allow being hurt
################################################
func _on_visible_on_screen_notifier_2d_right_screen_entered() -> void:
	speed = onscreen_speed
	movement_timer.start()

	# Enable collisions when on screen, to be able to be hurt/killed
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)


################################################
# NOTE: Despawn after leaving screen
################################################
func _on_visible_on_screen_notifier_2d_right_screen_exited() -> void:
	# Despawn when it leaves screen
	call_deferred("queue_free")


################################################
# NOTE: Hit by player's bullets or bombs
################################################
func _on_area_entered(area:Area2D) -> void:
	if area is PlayerBullet: 
		hp -= area.damage
		SignalsBus.score_increased_event.emit(hit_score)
	
	elif area is BombFuzz:
		damage_from_bomb = area.damage
		hp -= damage_from_bomb
		dot_timer.start()
	
	_health_based_actions()


################################################
# NOTE: Stop damage over time when bomb despawns
################################################
func _on_area_exited(area:Area2D) -> void:
	if area is BombFuzz:
		dot_timer.stop()


################################################
# NOTE: Damage over time when hit by bomb
################################################
func _on_dot_timer_timeout() -> void:
	hp -= damage_from_bomb
	SignalsBus.score_increased_event.emit(dot_score)

	_health_based_actions()


################################################
# NOTE: Heavier damage when player character runs into doomboard
################################################
func _on_body_entered(body:Node2D) -> void:
	if body is PlayerCat:
		hp -= body.damage
		SignalsBus.score_increased_event.emit(hit_score)
	
	_health_based_actions()


################################################
# NOTE: Helper func to handle low health or death
################################################
func _health_based_actions() -> void:
	if hp > 0 && hp <= low_hp_threshold:
		sprite.play("damaged")
	elif hp <= 0:
		if !dot_timer.is_stopped():
			dot_timer.stop()
		_handle_death()


################################################
# NOTE: Helper func to handle death
################################################
func _handle_death() -> void:
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	
	sprite.play("death")
	particles.emitting = true

	SignalsBus.score_increased_event.emit(kill_score)

	# Signal to spawn powerup
	SignalsBus.spawn_powerup_event.emit(self.global_position)
	
	# Signal to spawn score fragments on death
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	await sprite.animation_finished

	call_deferred("queue_free")


################################################
# NOTE: Ready
################################################
func _on_movement_timer_timeout() -> void:
	_movement_variation()

func _movement_variation() -> void:
	var dist_to_top : float = abs(self.global_position.y - 0)
	var dist_to_bot : float = abs(self.global_position.y - viewport_size.y)

	# If further from top of screen, move towards top, else move towards bottom
	if dist_to_top > dist_to_bot:
		direction = Vector2(-viewport_size.x, -viewport_size.y).normalized()
	else:
		direction = Vector2(-viewport_size.x, viewport_size.y).normalized()


func _on_visible_on_screen_notifier_2d_left_screen_exited() -> void:
	# Cannot be hurt/killed when flying offscreen to the left
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	
	speed = offscreen_speed
