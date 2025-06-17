class_name ScoreFragment extends Area2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var course_correction_timer : Timer = $course_correction_timer

@export var speed : float = 600.0
@export var course_correction_time : float = 0.3

var direction : Vector2
var nearest_score_item : Area2D

func _ready() -> void:
	_set_direction_to_nearest_score_item()
	_set_timer_properties()
	sprite.play("fly")


func _set_direction_to_nearest_score_item() -> void:
	if nearest_score_item == null:
		return
	direction = global_position.direction_to(nearest_score_item.global_position)


func _set_timer_properties() -> void:
	course_correction_timer.one_shot = false
	course_correction_timer.wait_time = course_correction_time
	course_correction_timer.start()


func _physics_process(delta: float) -> void:
	global_position += speed * delta * direction


## Despawn if it goes offscreen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	call_deferred("queue_free")


## Despawn if it reaches the score pickup item
func _on_area_entered(area:Area2D) -> void:
	if area is PickupScore && area == nearest_score_item:
		call_deferred("queue_free")


func _on_course_correction_timer_timeout() -> void:
	_set_direction_to_nearest_score_item()
