class_name PickupScore extends Area2D

@onready var sprite_small : AnimatedSprite2D = $sprite_small
@onready var sprite_medium : AnimatedSprite2D = $sprite_medium
@onready var sprite_large : AnimatedSprite2D = $sprite_large

@export var speed : float = 200.0


func _process(delta: float) -> void:
	global_position += speed * delta * Vector2.LEFT

################################################
#NOTE: Signal connection, when item leaves screen, it's despawned
################################################
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	call_deferred("queue_free")
