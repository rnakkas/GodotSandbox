class_name continue_screen extends Control

@onready var continue_time_left : Label = %time_left_label
@onready var tick_timer : Timer = $tick_timer

var continue_time : int = 10
const tick_time : int = 1

func _ready() -> void:
	continue_time_left.text = str(continue_time)
	
	tick_timer.wait_time = tick_time
	tick_timer.start()


func _on_tick_timer_timeout() -> void:
	continue_time -= tick_time
	
	if continue_time <= 0:
		tick_timer.stop()
	
	continue_time_left.text = str(continue_time)
		
