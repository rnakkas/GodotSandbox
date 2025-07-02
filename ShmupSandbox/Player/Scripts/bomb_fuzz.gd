class_name BombFuzz extends Area2D

@onready var bomb_sprite : AnimatedSprite2D = $bomb_sprite
@onready var bomb_collider : CollisionShape2D = $bomb_collider
@onready var detonation_timer : Timer = $detonation_timer

@export var speed : float = 150.0
@export var detonation_time : float = 1.0
@export var damage : int = 10

var viewport_size : Vector2


################################################
# NOTE: Ready
################################################
func _ready() -> void:
	viewport_size = get_viewport_rect().size
	_set_timer_properties()
	_play_animations()

func _set_timer_properties() -> void:
	detonation_timer.one_shot = true
	detonation_timer.wait_time = detonation_time
	detonation_timer.start()

func _play_animations() -> void:
	bomb_sprite.play("spawn")
	await bomb_sprite.animation_finished
	set_deferred("z_index", 0)
	bomb_sprite.play("fly")

################################################
# NOTE: Physics process
################################################
func _physics_process(delta: float) -> void:
	global_position += speed * delta * Vector2.RIGHT


################################################
# NOTE: Process
################################################
func _process(_delta: float) -> void:
	position = Helper.clamp_movement_to_screen_bounds(viewport_size, position)


################################################
# NOTE: Signal connection for detonation timer
################################################
func _on_detonation_timer_timeout() -> void:
	bomb_sprite.play("explode")
	speed = 0
	await bomb_sprite.animation_finished
	set_deferred("monitorable", false)
	call_deferred("queue_free")


################################################
# NOTE: Signal connection for on screen notifier
################################################
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# When bomb reaches right edge of screen, set speed to 0
	speed = 0
