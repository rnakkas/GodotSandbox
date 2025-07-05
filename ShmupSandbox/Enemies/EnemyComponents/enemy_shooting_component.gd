class_name EnemyShootingComponent extends Node2D

@export var shoot_timer : Timer
@export var shoot_time : float
@export var one_shot : bool
@export var bullet_scene : PackedScene
@export var targeted_shot : bool

## TODO:
	# Build this out for targeted shooting
	# Update the existing enemies and the new rumbler enemy to use this component

func _ready() -> void:
	if not shoot_timer:
		return
	Helper.set_timer_properties(shoot_timer, one_shot, shoot_time)    
	shoot_timer.timeout.connect(self._on_shoot_timer_timeout)


func _on_shoot_timer_timeout() -> void:
	if bullet_scene == null:
		return

	match targeted_shot:
		true:
			#_handle_targeted_shooting()
			pass
		false:
			_handle_non_targeted_shooting()


func _handle_non_targeted_shooting() -> void:
	var bullets_list : Array[Area2D]
	var bullet : EnemyBulletBasic = bullet_scene.instantiate()
	bullet.global_position = self.global_position # Can be changed later to a muzzle global position
	bullets_list.append(bullet)

	SignalsBus.enemy_shooting_event.emit(bullets_list)


func _on_screen_notifier_screen_entered() -> void:
	pass

func _on_screen_notifier_screen_exited() -> void:
	pass