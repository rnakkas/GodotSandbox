class_name BossWarningUi
extends Control

@onready var blink_timer: Timer = $blink_timer
@onready var warning_timer: Timer = $warning_timer

@onready var warning_label: Label = %warning_label
@onready var boss_specific_label: Label = %boss_specific_label

@export var blink_time: float = 0.5
@export var warning_time: float = 4.0

# signal boss_warning_ended()

func _ready() -> void:
	# Timer stuff
	blink_timer.timeout.connect(self._on_blink_timer_timeout)
	blink_timer.wait_time = blink_time
	blink_timer.one_shot = false

	warning_timer.timeout.connect(self._on_warning_timer_timeout)
	warning_timer.wait_time = warning_time
	warning_timer.one_shot = true

	# visibility
	visibility_changed.connect(self._on_visibility_changed)

	# Global signal
	SignalsBus.boss_incoming_warning_event.connect(self._on_boss_incoming_event)


func _on_boss_incoming_event(boss_message: String) -> void:
	boss_specific_label.text = boss_message


func _on_visibility_changed() -> void:
	if visible:
		blink_timer.start()
		warning_timer.start()

func _on_blink_timer_timeout() -> void:
	warning_label.visible = !warning_label.visible
	boss_specific_label.visible = !boss_specific_label.visible

func _on_warning_timer_timeout() -> void:
	blink_timer.stop()
	warning_label.visible = true
	boss_specific_label.visible = true
	SignalsBus.boss_warning_ended_event.emit()