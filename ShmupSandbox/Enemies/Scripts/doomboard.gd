class_name Doomboard extends Node2D

const offscreen_speed : float = 200.0
const onscreen_speed : float = 45.0

@export var speed : float = offscreen_speed

## TODO:
	#### Change doomboard to Node2D type, add a hurtbox component to handle hurt/death logic, so i can reuse for other enemies
	# - spawn offscreen right side - TODO: awaiting spawn scheduler work
	# - when spawned offscreen, move at a faster speed until on screen - DONE
	# - when offscreen cannot be damaged, disable collisions - DONE
	# - when on screen, enable collisions - DONE
	# - when onscreen, move at a slower speed towards the left - DONE
	# - timer: on timeout move towards center of player's y coordinates
	# - when offscreen right, despawn - DONE
	# - when hit, take damage
	# - if below 50% health, play damaged animation instead of idle
	# - if health depleted, dies and play death animation
	# - on death, signal to spawn powerup at death position


func _physics_process(delta: float) -> void:
	global_position += speed * delta * Vector2.LEFT


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	speed = onscreen_speed


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Despawn when it leaves screen
	call_deferred("queue_free")


func _on_hurtbox_component_health_depleted() -> void:
	call_deferred("queue_free")
