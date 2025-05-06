class_name StartScreen extends Control

@onready var press_start_label : Label = %press_start_label
@onready var blink_timer : Timer = $blink_timer

@export var idle_blink_time : float = 0.5
@export var pressed_blink_time : float = 0.1

var input_enabled : bool = false

signal start_pressed()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_blink_timer_properties(idle_blink_time)
	blink_timer.start()
	await get_tree().create_timer(0.7).timeout
	input_enabled = true

func _set_blink_timer_properties(blink_time : float) -> void:
	blink_timer.wait_time = blink_time
	blink_timer.one_shot = false


func _input(event: InputEvent) -> void:
	# Ignore mouse movement noise/events
	if event is InputEventMouseMotion:
		return
	
	if event.is_pressed() && input_enabled:
		input_enabled = false
		_set_blink_timer_properties(pressed_blink_time)
		await get_tree().create_timer(1.0).timeout
		start_pressed.emit()


## Blinking the press start label
func _on_blink_timer_timeout() -> void:
	press_start_label.visible = !press_start_label.visible
