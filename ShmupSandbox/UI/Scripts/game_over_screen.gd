class_name GameOverScreen extends Control

@export var game_over_screen_time : int = 2

@onready var game_over_timer : Timer = $game_over_timer

signal game_over_screen_timed_out()

func _ready() -> void:
	Helper.set_timer_properties(game_over_timer, true, game_over_screen_time)


func _on_game_over_timer_timeout() -> void:
	game_over_screen_timed_out.emit()


func _on_visibility_changed() -> void:
	if self.visible:
		game_over_timer.start()
