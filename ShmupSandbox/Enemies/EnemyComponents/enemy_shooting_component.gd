class_name EnemyShootingComponent extends Node2D

## Timer for shooting
@export var shoot_timer: Timer

## Time to wait before each shot, in seconds
@export var shoot_time: float

## Timer's one shot property
@export var one_shot: bool

## Number of bullets per shot
@export var bullets_per_shot: int = 1

## The total spread angle of each shot, in degrees
@export var shot_spread_angle: float = 0

## Specific bullet packed scene to use for the enemy
@export var bullet_scene: PackedScene

## Targeted or non targeeted shooting. 
## False: shoots straight ahead. 
## True: shoots at the player.
@export var targeted_shot: bool

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
			_handle_targeted_shooting()
			pass
		false:
			_handle_non_targeted_shooting()


func _handle_non_targeted_shooting() -> void:
	var bullets_list: Array[Area2D]
	var bullet: EnemyBulletBasic = bullet_scene.instantiate()
	bullet.global_position = self.global_position # Can be changed later to a muzzle global position
	bullets_list.append(bullet)

	SignalsBus.enemy_shooting_event.emit(bullets_list)


func _handle_targeted_shooting() -> void:
	# Don't shoot if there is no player
	if not GameManager.player:
		return
	
	# Don't shoot if player is dead
	if GameManager.player.is_dead:
		return
	
	# Main shooting logic
	var player_position: Vector2 = self.global_position.direction_to(GameManager.player.global_position)
	var bullets_list: Array[Area2D] = []
	var bullet: EnemyBulletBasic = SceneManager.screamer_bullet_scene.instantiate()
	
	bullet.global_position = self.global_position
	bullet.direction = player_position
	bullet.angle_deg = self.global_position.angle_to(GameManager.player.global_position)
	bullets_list.append(bullet)
	
	SignalsBus.enemy_shooting_event.emit(bullets_list)
