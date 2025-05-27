class_name PlayerBullet extends Area2D

@export var speed : float = 950.0

@onready var bullet_sprite : AnimatedSprite2D = $bullet_sprite

## TODO: use for od bullet shooting spread
var angle_deg : float = 0.0
var direction : Vector2 = Vector2.RIGHT

func _ready() -> void:
	direction = direction.rotated(deg_to_rad(angle_deg))
	bullet_sprite.rotate(deg_to_rad(angle_deg))

func _physics_process(delta: float) -> void:
	global_position += speed * delta * direction

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	call_deferred("queue_free")

## Hits enemy or object
func _on_area_entered(_area: Area2D) -> void:
	## Deactivate bullet collisions
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	
	speed = 0.0
	
	bullet_sprite.play("hit")
	await bullet_sprite.animation_finished
	
	
	call_deferred("queue_free")
	
