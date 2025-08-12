class_name StageClearScreen
extends Control

@onready var clear_bonus_value: Label = %clear_bonus_value
@onready var enemy_bonus_value: Label = %enemy_bonus_value
@onready var lives_bonus_value: Label = %lives_bonus_value
@onready var credits_bonus_value: Label = %credits_bonus_value
@onready var bomb_bonus_value: Label = %bomb_bonus_value

@onready var catnip_bonus_value: Label = %catnip_bonus_value
@onready var catnip_bonus_status: Label = %catnip_bonus_status

@onready var boss_bonus_value: Label = %boss_bonus_value

@onready var total_bonus_value: Label = %total_bonus_value

@onready var screen_timer: Timer = $screen_timer

@export var screen_time: float = 2.0


func _ready() -> void:
	_initialiaze_screen()
	screen_timer.one_shot = true
	screen_timer.wait_time = screen_time
	_connect_to_signals()
	

func _initialiaze_screen() -> void:
	clear_bonus_value.visible = false
	enemy_bonus_value.visible = false
	lives_bonus_value.visible = false
	credits_bonus_value.visible = false
	bomb_bonus_value.visible = false
	catnip_bonus_value.visible = false
	catnip_bonus_status.visible = false
	boss_bonus_value.visible = false
	total_bonus_value.visible = false


func _connect_to_signals() -> void:
	visibility_changed.connect(self._on_visibility_changed)
	screen_timer.timeout.connect(self._on_screen_timer_timeout)
	

func _on_visibility_changed() -> void:
	if visible:
		print_debug("start doing the score calculations stuff")

func _on_screen_timer_timeout() -> void:
	print_debug("hide stage clear screen")
