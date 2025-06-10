class_name BombHandler extends Node2D

@onready var bomb_muzzle : Marker2D = $muzzle_bomb
@onready var bomb_cooldown_timer : Timer = $bomb_cooldown_timer

@export var bomb_fuzz_scene : PackedScene = preload("res://ShmupSandbox/Player/Scenes/bomb_fuzz.tscn")
@export var bomb_cooldown_time : float = 2.0

var on_cooldown : bool
var is_dead : bool

################################################
# NOTE: Ready
################################################
func _ready() -> void:
	bomb_cooldown_timer.one_shot = true
	bomb_cooldown_timer.wait_time = bomb_cooldown_time


################################################
# NOTE: Input event for bombing
################################################
func _input(event: InputEvent) -> void:
	if is_dead:
		return
	
	if GameManager.player_bombs <= 0:
		return
	
	if event.is_action_pressed("bomb") && !on_cooldown:
		on_cooldown = true
		bomb_cooldown_timer.start()
		_bombing_behaviour()

################################################
# NOTE: Main function for bombing behavior
################################################
func _bombing_behaviour() -> void:
	GameManager.player_bombs -= 1
	
	SignalsBus.player_bombs_updated_event.emit()

	var bomb_fuzz : BombFuzz = bomb_fuzz_scene.instantiate()
	bomb_fuzz.position = bomb_muzzle.global_position
	
	SignalsBus.player_bombing_event.emit(bomb_fuzz)


################################################
# NOTE: Timer signal connection for cooldown refresh
################################################
func _on_bomb_cooldown_timer_timeout() -> void:
	on_cooldown = false
