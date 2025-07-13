class_name EnemyShootingComponent extends Node2D

## Timer for shooting
@export var shoot_timer: Timer

## Time to wait before each shot, in seconds
@export var shoot_time: float

## Timer's one shot property
@export var one_shot: bool

## Number of bullets per shot
@export var bullets_per_shot: int = 1

## Direction of the bullets. Only used for Non Targeted shooting type. Ignored if value is Vector2(0,0)
@export var bullet_direction: Vector2

## Bullet speed. Used to override the default speed of instantiated bullets. Ignored if value is zero
@export var bullet_speed: float

## Angle of shot bullet. Defaults to 180 (points to Vector2.LEFT)
@export var default_bullet_angle: float = 180.0

## The total spread angle of each shot, in degrees
@export var shot_spread_angle: float = 0

## Specific bullet packed scene to use for the enemy
@export var bullet_scene: PackedScene

enum shooting_type_enum {
	## Shoots straight ahead
	NON_TARGETED,
	## Shoots at player
	TARGETED,
}

## Shooting type
@export var shooting_type: shooting_type_enum


################################################
# Ready
################################################
func _ready() -> void:
	if not shoot_timer:
		return
	Helper.set_timer_properties(shoot_timer, one_shot, shoot_time)
	shoot_timer.timeout.connect(self._on_shoot_timer_timeout)


################################################
# Shooting logic based on shooting type
################################################
func _on_shoot_timer_timeout() -> void:
	if bullet_scene == null:
		return

	match shooting_type:
		shooting_type_enum.NON_TARGETED:
			_handle_non_targeted_shooting()
		shooting_type_enum.TARGETED:
			_handle_targeted_shooting()


################################################
# Non targeted shooting
################################################
func _handle_non_targeted_shooting() -> void:
	# Value with which to increment bullet angles
	var angle_step_deg: float
	var current_bullet_angle_deg: float = default_bullet_angle

	# If only 1 bullet per shot, bullet always points straight to the left, i.e. 180.0 degrees
	# Otherwise set the first bullet's angle to be minimum angle value in the spread
	if bullets_per_shot > 1:
		angle_step_deg = shot_spread_angle / (bullets_per_shot - 1)
		current_bullet_angle_deg -= (angle_step_deg * ((float(bullets_per_shot) - 1) / 2))

	SignalsBus.enemy_shooting_event.emit(_populate_bullets_list(current_bullet_angle_deg, angle_step_deg))


################################################
# Targeted shooting
################################################
func _handle_targeted_shooting() -> void:
	# Don't shoot if there is no player
	if not GameManager.player:
		return
	
	# Don't shoot if player is dead
	if GameManager.player.is_dead:
		return

	# Get angle to player
	var angle_to_player_deg: float = rad_to_deg(self.global_position.angle_to_point(GameManager.player.global_position))
	
	# Value with which to increment bullet angles
	var angle_step_deg: float
	
	# If only 1 bullet per shot, bullet always points at player
	var current_bullet_angle_deg: float = angle_to_player_deg
	if bullets_per_shot > 1:
		angle_step_deg = shot_spread_angle / (bullets_per_shot - 1)
		current_bullet_angle_deg = angle_to_player_deg - angle_step_deg

	SignalsBus.enemy_shooting_event.emit(_populate_bullets_list(current_bullet_angle_deg, angle_step_deg))


################################################
# Helper func to populate the bullets list
#	To be used by non targeted and targeted shooting
################################################
func _populate_bullets_list(current_bullet_angle_deg, angle_step_deg: float) -> Array[Area2D]:
	var bullets_list: Array[Area2D] = []
	var bullet: EnemyBulletBasic
	
	for i: int in range(bullets_per_shot):
		bullet = bullet_scene.instantiate()
		bullet.global_position = self.global_position
		bullet.angle_deg = current_bullet_angle_deg
		
		# Override bullet direction if one is provided for non targeted shooting
		if shooting_type == shooting_type_enum.NON_TARGETED && bullet_direction != Vector2.ZERO:
			bullet.direction = bullet_direction
		
		# Override bullet speed if one is provided
		if bullet_speed != 0:
			bullet.speed = bullet_speed
		
		bullets_list.append(bullet)
		current_bullet_angle_deg += angle_step_deg
	
	return bullets_list
