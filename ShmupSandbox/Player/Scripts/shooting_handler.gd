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
	# - emit global signal/event - to add bullets to the game when shooting

@export var fire_rate : float = 8.0
@export var bullet_scene : PackedScene = preload("res://ShmupSandbox/Player/Scenes/player_bullet.tscn")

@onready var muzzle : Marker2D = $muzzle

signal now_shooting()
signal stopped_shooting()

var is_dead: bool
var on_shooting_cooldown : bool
var shooting_cooldown_time : float

func _ready() -> void:
	shooting_cooldown_time = 1/fire_rate

func _process(_delta: float) -> void:
	_handle_shooting()

func _handle_shooting() -> void:
	if Input.is_action_pressed("shoot"):
		if !on_shooting_cooldown:
			on_shooting_cooldown = true
			
			var locations : Array[Vector2] = [muzzle.global_position]
			now_shooting.emit()
			SignalsBus.player_shooting_event(bullet_scene, locations)
			
			await get_tree().create_timer(shooting_cooldown_time).timeout
			on_shooting_cooldown = false
	else:
		stopped_shooting.emit()
