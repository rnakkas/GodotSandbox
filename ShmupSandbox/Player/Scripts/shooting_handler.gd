class_name ShootingHandler extends Node2D

## Constants
const powerup_level_max : int = 4

## Base fire rate
@export var fire_rate : float = 8.0

## Bullet scenes
@export var base_bullet_scene : PackedScene = preload("res://ShmupSandbox/Player/Scenes/base_bullet.tscn")
@export var od_bullet_scene : PackedScene = preload("res://ShmupSandbox/Player/Scenes/od_bullet.tscn")
@export var ch_lvl_1_bullet_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/ch_bullet_lvl_1.tscn")
@export var ch_lvl_2_bullet_scene : PackedScene = preload("res://ShmupSandbox/Player/Scenes/ch_bullet_lvl_2.tscn")
@export var ch_lvl_3_bullet_scene : PackedScene = preload("res://ShmupSandbox/Player/Scenes/ch_bullet_lvl_3.tscn")

## Default: no powerups, change only when powerup is picked up
@export var current_powerup : GameManager.powerups = GameManager.powerups.None
@export_range(0,powerup_level_max) var powerup_level: int = 0 # Powerup level can only be between 0 to 4

## Overdrive powerup shooting params
@export var od_spread_angle_deg : float
@export var od_bullets_per_shot : int		

## Chorus powerup shooting params
@export var ch_convergence_angle_deg : float = 5.5
@export var ch_lvl4_speed_multiplier : float = 0.75

## Muzzles
@onready var muzzle : Marker2D = $muzzle_base
@onready var muzzle_ch_1 : Marker2D = %muzzle_ch_1
@onready var muzzle_ch_2 : Marker2D = %muzzle_ch_2

## Shot limits
@export var base_shot_limit : int = 6

@export var od_lvl_1_shot_limit : int = 21
@export var od_lvl_2_shot_limit : int = 35
@export var od_lvl_3_shot_limit : int = 49
@export var od_lvl_4_shot_limit : int = 63

@export var ch_lvl_1_shot_limit : int = 10
@export var ch_lvl_2_3_shot_limit : int = 12
@export var ch_lvl_4_shot_limit : int = 36

## Signals
signal now_shooting(powerup : GameManager.powerups, level : int)
signal stopped_shooting()

## Misc variables
var is_dead: bool
var on_shooting_cooldown : bool
var shooting_cooldown_time : float
var angle_step : float
var location_base : Vector2
var location_ch_1 : Vector2
var location_ch_2 : Vector2
var bullets_list : Array[PlayerBullet] = []
var shot_limit_reached : bool


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
	var shot_limit : int = base_shot_limit
	
	match current_powerup:
		GameManager.powerups.Overdrive:
			match powerup_level:
				0:
					pass
				1:
					od_bullets_per_shot = 3
					od_spread_angle_deg = 8.0
					shot_limit = od_lvl_1_shot_limit
				2:
					od_bullets_per_shot = 5
					od_spread_angle_deg = 15.0
					shot_limit = od_lvl_2_shot_limit
				3:
					od_bullets_per_shot = 7
					od_spread_angle_deg = 25.0
					shot_limit = od_lvl_3_shot_limit
				4:
					od_bullets_per_shot = 9
					od_spread_angle_deg = 30.0
					shot_limit = od_lvl_4_shot_limit
			
			angle_step = od_spread_angle_deg/(od_bullets_per_shot-1)
		
		GameManager.powerups.Chorus:
			fire_rate = 18.0
			match powerup_level:
				0:
					pass
				1:
					shot_limit = ch_lvl_1_shot_limit
				2, 3:
					shot_limit = ch_lvl_2_3_shot_limit
				4:
					shot_limit = ch_lvl_4_shot_limit

	shooting_cooldown_time = 1/fire_rate

	SignalsBus.shot_limit_updated_event.emit(shot_limit)


################################################
# NOTE: Powerup pickeup signal connection
################################################
# NOTE: Only increase powerup level if the current powerup matches the pickeud up powerup, or if currently don't have a powerup
	# If picked up powerup is different, keep the powerup level the same
	# Can't go above 4 for the powerup level
	# Switch the current powerup to the picked up powerup (casting powerup as the enum)
	# Update shooting properties based on powerup picked up
func _on_powerup_picked_up(powerup : int, score : int) -> void:
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
	var bullet : PlayerBullet
	bullet = base_bullet_scene.instantiate()
	bullet.position = location_base
	bullets_list.append(bullet)

## Overdrive powerup shooting
func _od_shooting_behaviour() -> void:
	var bullet : PlayerBullet

	# Create the list of instantiated bullets
	for instance : int in range(od_bullets_per_shot):
		bullet = od_bullet_scene.instantiate()
		bullet.position = location_base
		bullets_list.append(bullet)
	
	# First bullet's angle
	var current_bullet_angle : float = -od_spread_angle_deg/2
	
	for bullet_instance : int in range(bullets_list.size()):
		bullets_list[bullet_instance].angle_deg = current_bullet_angle
		current_bullet_angle += angle_step # Increase angle by the step value for use in subsequent bullets

## Chorus powerup shooting
func _ch_shooting_behaviour() -> void:
	var bullet : PlayerBullet
	var bullet_ch_1 : PlayerBullet
	var bullet_ch_2 : PlayerBullet

	match powerup_level:
		0:
			pass
		1:
			bullet = ch_lvl_1_bullet_scene.instantiate()
		2:
			bullet = ch_lvl_2_bullet_scene.instantiate()
		3:
			bullet = ch_lvl_3_bullet_scene.instantiate()
		4:
			bullet = ch_lvl_3_bullet_scene.instantiate()
			bullet_ch_1 = ch_lvl_1_bullet_scene.instantiate()
			bullet_ch_2 = ch_lvl_1_bullet_scene.instantiate()

	bullet.position = location_base
	bullets_list.append(bullet)
	
	if bullet_ch_1 != null:
		bullet_ch_1.position = location_ch_1
		bullet_ch_1.angle_deg = ch_convergence_angle_deg
		bullet_ch_1.speed = bullet.speed*ch_lvl4_speed_multiplier
		bullets_list.append(bullet_ch_1)
	
	if bullet_ch_2 != null:
		bullet_ch_2.position = location_ch_2
		bullet_ch_2.angle_deg = -ch_convergence_angle_deg
		bullet_ch_2.speed = bullet.speed*ch_lvl4_speed_multiplier
		bullets_list.append(bullet_ch_2)