class_name rebel_fighter extends Area2D

@export var hp : int
@export var speed : float

@onready var enemy_sprite : AnimatedSprite2D = $body

func _physics_process(delta: float) -> void:
	global_position.y += speed * delta

func _process(_delta: float) -> void:
	handle_dying()

func handle_dying() -> void:
	if hp <= 0:
		deactivate_self()
		enemy_sprite.play("death")
		await enemy_sprite.animation_finished
		queue_free()

func deactivate_self() -> void:
	speed = 0.0
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

## Hit by player's bullets
func _on_area_entered(_area: Area2D) -> void:
	hp -= 1
