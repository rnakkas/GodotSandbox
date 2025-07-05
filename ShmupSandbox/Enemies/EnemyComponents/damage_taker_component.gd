class_name DamageTakerComponent extends Area2D

# Default health, change this per enemy
@export var max_hp : int = 1 

# Timer for damage over time, i.e. for player bombs. Can be null for enemies that die in one hit
@export var dot_timer : Timer 

const dot_time : float = 0.35

var hp : int
var low_hp_threshold : int
var damage_from_bomb: int

signal damage_taken()
signal low_health()
signal health_depleted()

func _ready() -> void:
	_connect_to_own_signals()
	
	hp = max_hp
	low_hp_threshold = round((max_hp as float)/3)

	# Default collision layer and mask values
	collision_layer = 8 # Layer name: enemy
	collision_mask = 67 # Mask names: player, player_bullet, player_bomb

	if dot_timer:
		Helper.set_timer_properties(dot_timer, false, dot_time)


# Programmatically connect to own area monitoring signals
func _connect_to_own_signals() -> void:
	area_entered.connect(self._on_area_entered)
	area_exited.connect(self._on_area_exited)
	body_entered.connect(self._on_body_entered)

	if dot_timer:
		dot_timer.timeout.connect(self._on_dot_timer_timeout)


# Getting hit by player's bullets or bombs
func _on_area_entered(area:Area2D) -> void:
	if area is PlayerBullet: 
		if hp <= 0: # Do nothing if hp is already zero
			return
		hp -= area.damage
		damage_taken.emit()

	elif area is BombFuzz:
		damage_from_bomb = area.damage
		hp -= damage_from_bomb

		if dot_timer:
			dot_timer.start()
	
	_health_based_actions()


# When player's bomb ends
func _on_area_exited(area:Area2D) -> void:
	if area is BombFuzz:
		if dot_timer:
			dot_timer.stop()


# Damage over time when in player bomb area
func _on_dot_timer_timeout() -> void:
	hp -= damage_from_bomb
	damage_taken.emit()

	_health_based_actions()


# Getting hit by the player
func _on_body_entered(body:Node2D) -> void:
	if body is PlayerCat:
		if body.is_dead: # Don't collide with dead player
			return
		hp -= body.damage
		damage_taken.emit()
	
	_health_based_actions()


# Helper function for various health related actions
func _health_based_actions() -> void:
	if hp > 0 && hp <= low_hp_threshold:
		low_health.emit()
	elif hp <= 0:
		if dot_timer && !dot_timer.is_stopped():
			dot_timer.stop()
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
		health_depleted.emit()
