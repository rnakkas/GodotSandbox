class_name player_spawn_sprite extends AnimatedSprite2D

@export var speed : float = 350.0
@onready var on_screen_notifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D


func _physics_process(delta: float) -> void:
	global_position.x += speed * delta


## When it reaches the spawn point
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	SignalsBus.player_spawn_ready(global_position)
	call_deferred("queue_free")
