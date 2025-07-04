class_name DamageTakerComponent extends Area2D

@export var max_hp : int = 20
@export var dot_timer : Timer

const dot_time : float = 0.4

var hp : int = max_hp
var low_hp_threshold : int = round((max_hp as float)/3)
var damage_from_bomb: int

signal damage_taken()
signal low_health()
signal health_depleted()

func _ready() -> void:
	_connect_to_own_signals()
	Helper.set_timer_properties(dot_timer, false, dot_time)


func _connect_to_own_signals() -> void:
	area_entered.connect(self._on_area_entered)
	area_exited.connect(self._on_area_exited)
	body_entered.connect(self._on_body_entered)


func _on_area_entered(area:Area2D) -> void:
	if area is PlayerBullet: 
		hp -= area.damage
		damage_taken.emit()
	
	elif area is BombFuzz:
		damage_from_bomb = area.damage
		hp -= damage_from_bomb
		dot_timer.start()
	
	_health_based_actions()


func _on_area_exited(area:Area2D) -> void:
	if area is BombFuzz:
		dot_timer.stop()


func _on_dot_timer_timeout() -> void:
	hp -= damage_from_bomb
	damage_taken.emit()

	_health_based_actions()


func _on_body_entered(body:Node2D) -> void:
	if body is PlayerCat:
		hp -= body.damage
		damage_taken.emit()
	
	_health_based_actions()


func _health_based_actions() -> void:
	if hp > 0 && hp <= low_hp_threshold:
		low_health.emit()
	elif hp <= 0:
		if !dot_timer.is_stopped():
			dot_timer.stop()
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
		health_depleted.emit()