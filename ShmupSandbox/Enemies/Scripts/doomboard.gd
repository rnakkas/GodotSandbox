class_name Doomboard extends Area2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var particles : CPUParticles2D = $CPUParticles2D
@onready var dot_timer : Timer = $dot_timer

@export var offscreen_speed_x : float = 200.0
@export var onscreen_speed_x : float = 12.5
@export var onscreen_speed_y : float = 20.0
@export var max_hp : int = 30
@export var hit_score : int = 10
@export var kill_score : int = 250
@export var dot_time : float = 0.3
@export var dot_score : int = 2
@export var offset_y_screen_bottom : float = 120.0
@export var offset_y_screen_top : float = 120.0

var hp : int = max_hp
var low_hp_threshold : int = round((max_hp as float)/3)
var damage_from_bomb: int
var can_die : bool

var direction : Vector2 = Vector2.LEFT
var move_speed : Vector2

var viewport_size : Vector2
var screen_top_thresh : float
var screen_bot_thresh: float


################################################
# NOTE: Ready
################################################
func _ready() -> void:
	# Get viewport size, set movement threshholds and direction
	_set_movement_thresholds()
	_set_direction()

	# Set speed
	move_speed = Vector2(offscreen_speed_x, onscreen_speed_y)

	# Disable collisions when spawned, will be enabled when it enters screen
	# To prevent being prematurely killed
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)

	Helper.set_timer_properties(dot_timer, false, dot_time)

func _set_movement_thresholds() -> void:
	viewport_size = get_viewport_rect().size
	screen_top_thresh = 0 + offset_y_screen_top
	screen_bot_thresh = viewport_size.y - offset_y_screen_bottom

func _set_direction() -> void:
	if global_position.y <= screen_top_thresh:
		# Move down if top of screen
		direction.y = 1.0
	elif global_position.y >= screen_bot_thresh:
		# Move up if bottom of screen
		direction.y = -1.0

################################################
# NOTE: Physics process, movement and velocity
################################################
func _physics_process(delta: float) -> void:
	_set_direction()
	global_position += move_speed * delta * direction


################################################
# NOTE: When onscreen change to onscreen speeds, allow being hurt
################################################
func _on_visible_on_screen_notifier_2d_right_screen_entered() -> void:
	move_speed = Vector2(onscreen_speed_x, onscreen_speed_y)
	direction.y = 1.0

	# Enable collisions when on screen, to be able to be hurt/killed
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)


################################################
# NOTE: When near the left of screen, move faster to fly offscreen
################################################
func _on_visible_on_screen_notifier_2d_left_screen_exited() -> void:
	# Cannot be hurt/killed when flying offscreen to the left
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	
	move_speed = Vector2(offscreen_speed_x, onscreen_speed_y)
	direction.y = 0.0


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
