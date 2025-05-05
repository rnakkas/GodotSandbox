class_name PlayerSpawnSprite extends AnimatedSprite2D

@export var speed : float = 350.0
@onready var on_screen_notifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D


func _physics_process(delta: float) -> void:
	global_position.x += speed * delta


## When it reaches the spawn point
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	var can_be_invincible : bool
	
	if self.animation == "spawn":
		can_be_invincible = false
	if self.animation == "respawn":
		can_be_invincible = true
	
	SignalsBus.player_spawn_event(global_position, can_be_invincible)
	
	call_deferred("queue_free")
