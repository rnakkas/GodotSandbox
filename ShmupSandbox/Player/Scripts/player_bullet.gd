class_name player_bullet extends Area2D

@export var speed : float

@onready var bullet_sprite : AnimatedSprite2D = $bullet_sprite

func _physics_process(delta: float) -> void:
	global_position.y -= speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

## Hits enemy or object
func _on_area_entered(_area: Area2D) -> void:
	## Deactivate bullet collisions
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	
	speed = 0.0
	
	bullet_sprite.play("hit")
	await bullet_sprite.animation_finished
	
	queue_free()
	
