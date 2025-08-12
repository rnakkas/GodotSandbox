class_name StageClearScreen
extends Control

@onready var clear_bonus_value: Label = %clear_bonus_value
@onready var enemy_bonus_value: Label = %enemy_bonus_value
@onready var lives_bonus_value: Label = %lives_bonus_value
@onready var credits_bonus_value: Label = %credits_bonus_value
@onready var bomb_bonus_value: Label = %bomb_bonus_value
@onready var boss_bonus_value: Label = %boss_bonus_value

@onready var catnip_bonus_value: Label = %catnip_bonus_value
@onready var catnip_slot_1: TextureRect = %catnip_slot_1
@onready var catnip_slot_2: TextureRect = %catnip_slot_2
@onready var catnip_slot_3: TextureRect = %catnip_slot_3
@onready var catnip_slot_4: TextureRect = %catnip_slot_4
@onready var catnip_slot_5: TextureRect = %catnip_slot_5
@onready var catnip_bonus_status: Label = %catnip_bonus_status

@onready var screen_timer: Timer = $screen_timer

@export var screen_time: float = 2.0


## Stage clear screen:
	# When boss is killed, this screen becomes visible
	# Connects to the stage_clear_event global signal 
	#	to get clear bonus, enemies killed, boss bonus and full catnip bonus for the level
	# Calculate and display the score bonuses in sequence (as per ui)
	# Display the catnips collected, based on how many collected display the special catnip status
	# On a tick timer, drain the bonuses and update the hud with the added scores
	# Once all done, send signal to hide this screen

func _ready() -> void:
	_initialiaze_screen()
	_connect_to_signals()
	screen_timer.one_shot = true
	screen_timer.wait_time = screen_time
	

func _initialiaze_screen() -> void:
	clear_bonus_value.visible = false
	enemy_bonus_value.visible = false
	lives_bonus_value.visible = false
	credits_bonus_value.visible = false
	bomb_bonus_value.visible = false
	boss_bonus_value.visible = false
	catnip_bonus_value.visible = false
	catnip_bonus_status.visible = false
	catnip_slot_1.visible = false
	catnip_slot_2.visible = false
	catnip_slot_3.visible = false
	catnip_slot_4.visible = false
	catnip_slot_5.visible = false


func _connect_to_signals() -> void:
	visibility_changed.connect(self._on_visibility_changed)
	screen_timer.timeout.connect(self._on_screen_timer_timeout)
	

func _on_visibility_changed() -> void:
	if visible:
		print_debug("start doing the score calculations stuff")


func _on_screen_timer_timeout() -> void:
	print_debug("hide stage clear screen")
