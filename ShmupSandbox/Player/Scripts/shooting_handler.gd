class_name ShootingHandler extends Node2D

## Constants
const powerup_level_max: int = 4

## Base fire rate
@export var base_fire_rate: float = 6.0

## OD fire rate
@export var od_fire_rate: float = 7.75

## Chorus fire rate
@export var ch_lvl_1_fire_rate: float = 20.0
@export var ch_lvl_2_fire_rate: float = 22.5
@export var ch_lvl_3_fire_rate: float = 25.0
@export var ch_lvl_4_fire_rate: float = 28.0

## Default: no powerups, change only when powerup is picked up
@export var current_powerup: GameManager.powerups = GameManager.powerups.None

## Powerup level can only be between 0 to 4
@export_range(0, powerup_level_max) var powerup_level: int = 0

## Overdrive powerup shooting params
@export var od_lvl_1_spread_angle_deg: float = 10.0
@export var od_lvl_2_spread_angle_deg: float = 12.5
@export var od_lvl_3_spread_angle_deg: float = 15.0
@export var od_lvl_4_spread_angle_deg: float = 20.0

@export var od_lvl_1_bullets_per_shot: int = 3
@export var od_lvl_2_bullets_per_shot: int = 5
@export var od_lvl_3_bullets_per_shot: int = 7
@export var od_lvl_4_bullets_per_shot: int = 9


## Chorus powerup shooting params
@export var ch_convergence_angle_deg: float = 5.5
@export var ch_lvl4_speed_multiplier: float = 0.75

## Muzzles
@onready var muzzle: Marker2D = $muzzle_base
@onready var muzzle_ch_1: Marker2D = %muzzle_ch_1
@onready var muzzle_ch_2: Marker2D = %muzzle_ch_2

## Shot limits
@export var base_shot_limit: int = 50

@export var od_lvl_1_shot_limit: int = 100
@export var od_lvl_2_shot_limit: int = 150
@export var od_lvl_3_shot_limit: int = 200
@export var od_lvl_4_shot_limit: int = 300

@export var ch_lvl_1_shot_limit: int = 150
@export var ch_lvl_2_3_shot_limit: int = 150
@export var ch_lvl_4_shot_limit: int = 300

## Base bullet damage
@export var base_bullet_damage: int = 2

## OD bullet damage
@export var od_bullet_damage: int = 1

## Chorus bullet damage
@export var ch_bullet_damage: int = 1


## Signals
signal now_shooting(powerup: GameManager.powerups, level: int)
signal stopped_shooting()

## Misc variables
var is_dead: bool
var on_shooting_cooldown: bool
var shooting_cooldown_time: float
var angle_step: float
var location_base: Vector2
var location_ch_1: Vector2
var location_ch_2: Vector2
var bullets_list: Array[PlayerBullet] = []
var shot_limit_reached: bool
var fire_rate: float
var od_spread_angle_deg: float
var od_bullets_per_shot: int


################################################
# NOTE: Ready
################################################
func _ready() -> void:
	_connect_to_signals()
	_update_shooting_properties()

func _connect_to_signals() -> void:
	# Auto disconnects if this node is freed
	SignalsBus.powerup_collected_event.connect(self._on_powerup_picked_up)
	SignalsBus.shot_limit_reached_event.connect(self._on_shot_limit_reached)
	SignalsBus.shot_limit_refreshed_event.connect(self._on_shot_limit_refreshed)


################################################
# NOTE: Update shooting properties based on powerup
################################################
func _update_shooting_properties() -> void:
	var shot_limit: int = base_shot_limit
	fire_rate = base_fire_rate
	
	match current_powerup:
		GameManager.powerups.Overdrive:
			fire_rate = od_fire_rate
			match powerup_level:
				0:
					pass
				1:
					od_bullets_per_shot = od_lvl_1_bullets_per_shot
					od_spread_angle_deg = od_lvl_1_spread_angle_deg
					shot_limit = od_lvl_1_shot_limit
				2:
					od_bullets_per_shot = od_lvl_2_bullets_per_shot
					od_spread_angle_deg = od_lvl_2_spread_angle_deg
					shot_limit = od_lvl_2_shot_limit
				3:
					od_bullets_per_shot = od_lvl_3_bullets_per_shot
					od_spread_angle_deg = od_lvl_3_spread_angle_deg
					shot_limit = od_lvl_3_shot_limit
				4:
					od_bullets_per_shot = od_lvl_4_bullets_per_shot
					od_spread_angle_deg = od_lvl_4_spread_angle_deg
					shot_limit = od_lvl_4_shot_limit
			
			angle_step = od_spread_angle_deg / (od_bullets_per_shot - 1)
		
		GameManager.powerups.Chorus:
			match powerup_level:
				0:
					pass
				1:
					shot_limit = ch_lvl_1_shot_limit
					fire_rate = ch_lvl_1_fire_rate
				2:
					shot_limit = ch_lvl_2_3_shot_limit
					fire_rate = ch_lvl_2_fire_rate
				3:
					shot_limit = ch_lvl_2_3_shot_limit
					fire_rate = ch_lvl_3_fire_rate
				4:
					shot_limit = ch_lvl_4_shot_limit
					fire_rate = ch_lvl_4_fire_rate

	shooting_cooldown_time = 1 / fire_rate

	SignalsBus.shot_limit_updated_event.emit(shot_limit)


################################################
# NOTE: Powerup pickeup signal connection
################################################
# NOTE: Only increase powerup level if the current powerup matches the pickeud up powerup, or if currently don't have a powerup
	# If picked up powerup is different, keep the powerup level the same
	# Can't go above 4 for the powerup level
	# Switch the current powerup to the picked up powerup (casting powerup as the enum)
	# Update shooting properties based on powerup picked up
func _on_powerup_picked_up(powerup: int, score: int) -> void:
	# If powerup picked up is bomb, don't modify shooting
	if powerup == 3: # Fuzz
		return

	# Add score if powerup is at max level
	if powerup_level == powerup_level_max && current_powerup == powerup:
		SignalsBus.score_increased_event.emit(score)
		return

	# Increase powerup level if same type picked up
	if current_powerup == GameManager.powerups.None || current_powerup == powerup:
		powerup_level += 1

	powerup_level = clamp(powerup_level, 0, 4)
	current_powerup = powerup as GameManager.powerups

	if powerup_level == powerup_level_max:
		SignalsBus.powerup_max_level_event.emit(current_powerup)

	_update_shooting_properties()


################################################
# NOTE: Shot limit reached and refreshed signals connections
################################################
func _on_shot_limit_reached() -> void:
	shot_limit_reached = true

func _on_shot_limit_refreshed() -> void:
	shot_limit_reached = false


################################################
# NOTE: Process
################################################
func _process(_delta: float) -> void:
	if is_dead:
		return
	_handle_shooting()


################################################
# NOTE: Main function for handling shooting
################################################
func _handle_shooting() -> void:
	# Set the muzzle locations every frame
	location_base = muzzle.global_position
	location_ch_1 = muzzle_ch_1.global_position
	location_ch_2 = muzzle_ch_2.global_position

	# Only allow shooting if shot limit hasn't been reached
	if Input.is_action_pressed("shoot") && !shot_limit_reached:
		if !on_shooting_cooldown:
			on_shooting_cooldown = true

			# Clear out the bullets list for each shooting event
			bullets_list.clear()

			match current_powerup:
				GameManager.powerups.None:
					_base_shooting_behaviour()
				GameManager.powerups.Overdrive:
					_od_shooting_behaviour()
				GameManager.powerups.Chorus:
					_ch_shooting_behaviour()

			# Emit the necessary signals
			now_shooting.emit(current_powerup, powerup_level)
			SignalsBus.player_shooting_event.emit(bullets_list)
			
			await get_tree().create_timer(shooting_cooldown_time).timeout
			on_shooting_cooldown = false
	else:
		stopped_shooting.emit()

## Base shooting
func _base_shooting_behaviour() -> void:
	var bullet: PlayerBullet
	bullet = SceneManager.base_bullet_scene.instantiate()
	bullet.position = location_base
	bullet.damage = base_bullet_damage
	bullets_list.append(bullet)

## Overdrive powerup shooting
func _od_shooting_behaviour() -> void:
	var bullet: PlayerBullet

	# Create the list of instantiated bullets
	for instance: int in range(od_bullets_per_shot):
		# Middle shot is the base bullet
		if instance == round(od_bullets_per_shot / 2):
			bullet = SceneManager.base_bullet_scene.instantiate()
		else:
			bullet = SceneManager.od_bullet_scene.instantiate()
		bullet.position = location_base
		bullet.damage = od_bullet_damage
		bullets_list.append(bullet)
	
	# First bullet's angle
	var current_bullet_angle: float = - od_spread_angle_deg / 2
	
	for bullet_instance: int in range(bullets_list.size()):
		bullets_list[bullet_instance].angle_deg = current_bullet_angle
		current_bullet_angle += angle_step # Increase angle by the step value for use in subsequent bullets

## Chorus powerup shooting
func _ch_shooting_behaviour() -> void:
	var bullet: PlayerBullet
	var bullet_ch_1: PlayerBullet
	var bullet_ch_2: PlayerBullet

	match powerup_level:
		0:
			pass
		1:
			bullet = SceneManager.ch_lvl_1_bullet_scene.instantiate()
		2:
			bullet = SceneManager.ch_lvl_2_bullet_scene.instantiate()
		3:
			bullet = SceneManager.ch_lvl_3_bullet_scene.instantiate()
		4:
			bullet = SceneManager.ch_lvl_3_bullet_scene.instantiate()
			bullet_ch_1 = SceneManager.ch_lvl_1_bullet_scene.instantiate()
			bullet_ch_2 = SceneManager.ch_lvl_1_bullet_scene.instantiate()

	bullet.position = location_base
	bullet.damage = ch_bullet_damage
	bullets_list.append(bullet)
	
	if bullet_ch_1 != null:
		bullet_ch_1.position = location_ch_1
		bullet_ch_1.angle_deg = ch_convergence_angle_deg
		bullet_ch_1.speed = bullet.speed * ch_lvl4_speed_multiplier
		bullets_list.append(bullet_ch_1)
	
	if bullet_ch_2 != null:
		bullet_ch_2.position = location_ch_2
		bullet_ch_2.angle_deg = - ch_convergence_angle_deg
		bullet_ch_2.speed = bullet.speed * ch_lvl4_speed_multiplier
		bullets_list.append(bullet_ch_2)