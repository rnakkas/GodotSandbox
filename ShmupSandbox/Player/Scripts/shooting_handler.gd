class_name ShootingHandler extends Node2D

#TODO: Will handle all the shooting logic for the player
## - Needs the following:
	# - muzzles - for base, od and ch shooting
	# - sends signals to parent player node for shooting and idle animations
	# - fire rate
	# - bullet scenes - for base, od and ch
	# - power up level
	# - od bullet angles
	# - od bullets per shot
	# - global signal connection - powerup type that was picked up
	# - emit global signal/event - to add bullets to the game when shooting - done

@export var fire_rate : float = 8.0

## Bullet scenes
@export var base_bullet_scene : PackedScene = preload("res://ShmupSandbox/Player/Scenes/base_bullet.tscn")
@export var od_bullet_scene : PackedScene = preload("res://ShmupSandbox/Player/Scenes/od_bullet.tscn")
@export var ch_lvl_1_bullet_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/ch_bullet_lvl_1.tscn")
@export var ch_lvl_2_bullet_scene : PackedScene = preload("res://ShmupSandbox/Player/Scenes/ch_bullet_lvl_2.tscn")
@export var ch_lvl_3_bullet_scene : PackedScene = preload("res://ShmupSandbox/Player/Scenes/ch_bullet_lvl_3.tscn")

# Default: no powerups, change only when powerup is picked up
@export var current_powerup : GameManager.powerups = GameManager.powerups.None 
# Default: 0 for base, only used when powerup is active
@export var powerup_level: int = 0							

# For overdrive powerup shooting params
@export var od_spread_angle_deg : float
@export var od_bullets_per_shot : int				

@onready var muzzle : Marker2D = $muzzle_base

signal now_shooting(powerup : GameManager.powerups)
signal stopped_shooting()

var is_dead: bool
var on_shooting_cooldown : bool
var shooting_cooldown_time : float
var angle_step : float

func _ready() -> void:
	_update_shooting_properties()
	SignalsBus.powerup_collected.connect(_on_powerup_picked_up)


func _on_powerup_picked_up(powerup : int) -> void:
	# Only increase powerup level if the current powerup matches the pickeud up powerup, or if currently don't have a powerup
	# If picked up powerup is different, keep the powerup level the same
	# Can't go above 4 for the powerup level
	# Switch the current powerup to the picked up powerup (casting powerup as the enum)
	# Update shooting properties based on powerup picked up

	if current_powerup == GameManager.powerups.None || current_powerup == powerup:
		powerup_level += 1

	powerup_level = clamp(powerup_level, 0, 4)
	current_powerup = powerup as GameManager.powerups
	_update_shooting_properties()

func _update_shooting_properties() -> void:
	match current_powerup:
		GameManager.powerups.Overdrive:
			match powerup_level:
				0:
					pass
				1:
					od_bullets_per_shot = 3
					od_spread_angle_deg = 8.0
				2:
					od_bullets_per_shot = 5
					od_spread_angle_deg = 15.0
				3:
					od_bullets_per_shot = 7
					od_spread_angle_deg = 25.0
				4:
					od_bullets_per_shot = 9
					od_spread_angle_deg = 30.0
			
			angle_step = od_spread_angle_deg/(od_bullets_per_shot-1)
		
		GameManager.powerups.Chorus:
			fire_rate = 25.0

	shooting_cooldown_time = 1/fire_rate


func _process(_delta: float) -> void:
	_handle_shooting()

## TODO: Clean up this code a bit
func _handle_shooting() -> void:
	if Input.is_action_pressed("shoot"):
		if !on_shooting_cooldown:
			on_shooting_cooldown = true
			
			var location : Vector2 = muzzle.global_position
			var bullet : PlayerBullet
			var bullets_list : Array[Area2D]

			match current_powerup:
				GameManager.powerups.None:
					bullet = base_bullet_scene.instantiate()
					bullets_list.append(bullet)
					bullet.position = location
				GameManager.powerups.Overdrive: ## TODO: change the angles of the overdrive bullets for cone spread
					for instance : int in range(od_bullets_per_shot):
						bullet = od_bullet_scene.instantiate()
						bullet.position = location
						bullets_list.append(bullet)
					
					var current_bullet_angle : float = -od_spread_angle_deg/2
					for bullet_instance : int in range(bullets_list.size()):
						bullets_list[bullet_instance].angle_deg = current_bullet_angle
						current_bullet_angle += angle_step
						print("current bullet angele: ", bullets_list[bullet_instance].angle_deg)

				GameManager.powerups.Chorus: ## TODO: need level 4 of chorus to be implemented
					match powerup_level:
						0:
							pass
						1:
							bullet = ch_lvl_1_bullet_scene.instantiate()
						2:
							bullet = ch_lvl_2_bullet_scene.instantiate()
						3:
							bullet = ch_lvl_3_bullet_scene.instantiate()
					bullet.position = location
					bullets_list.append(bullet)

			now_shooting.emit(current_powerup)

			SignalsBus.player_shooting_event(bullets_list)
			
			await get_tree().create_timer(shooting_cooldown_time).timeout
			on_shooting_cooldown = false
	else:
		stopped_shooting.emit()