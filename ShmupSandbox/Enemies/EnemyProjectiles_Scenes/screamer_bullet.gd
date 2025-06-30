class_name ScreamerBullet extends Area2D

@onready var sprite : AnimatedSprite2D = $sprite

@export var speed : float = 300.0

var direction : Vector2 = Vector2.LEFT

## TODO: 
	# Spritesheet
	# Animations

func _physics_process(delta: float) -> void:
	global_position += speed * delta * direction


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	call_deferred("queue_free")


func _on_area_entered(_area:Area2D) -> void:
	call_deferred("queue_free")


func _on_body_entered(body:Node2D) -> void:
	if body is PlayerCat:
		if body.is_dead:
			return
		call_deferred("queue_free")

