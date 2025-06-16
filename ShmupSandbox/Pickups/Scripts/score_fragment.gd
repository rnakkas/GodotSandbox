class_name ScoreFragment extends Area2D

@onready var sprite : AnimatedSprite2D = $sprite

@export var speed : float = 300.0

var direction : Vector2

func _ready() -> void:
	sprite.play("fly")


func _physics_process(delta: float) -> void:
	global_position += speed * delta * direction


## Despawn if it goes offscreen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	call_deferred("queue_free")


## Despawn if it reaches the score pickup item
func _on_area_entered(area:Area2D) -> void:
	if area is PickupScore:
		call_deferred("queue_free")
