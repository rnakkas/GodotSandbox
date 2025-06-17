class_name ScoreFragment extends Area2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var course_correction_timer : Timer = $course_correction_timer

@export var speed : float = 650.0
@export var course_correction_time : float = 0.3

var non_maxed_score_items_list : Array[PickupScore] = []
var direction : Vector2
var nearest_non_maxed_score_item : PickupScore

func _ready() -> void:
	_get_nearest_non_maxed_score_item()
	_set_direction_to_nearest_non_maxed_score_item()
	_set_timer_properties()
	sprite.play("fly")


func _get_nearest_non_maxed_score_item() -> void:
	var distance_to_score_item : float
	var score_item_distances_list : Array[float] = []
	var score_item_and_distance_map : Dictionary[PickupScore, float] = {}

	for score_item : PickupScore in non_maxed_score_items_list:
		distance_to_score_item = self.global_position.distance_to(score_item.global_position)
		score_item_distances_list.append(distance_to_score_item)
		score_item_and_distance_map[score_item] = distance_to_score_item

	score_item_distances_list.sort()
	
	for item : PickupScore in score_item_and_distance_map.keys():
		if score_item_and_distance_map[item] == score_item_distances_list[0]:
			nearest_non_maxed_score_item = item
			break


func _set_direction_to_nearest_non_maxed_score_item() -> void:
	if nearest_non_maxed_score_item == null:
		return
	direction = self.global_position.direction_to(nearest_non_maxed_score_item.global_position)


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
	if area is PickupScore && area == nearest_non_maxed_score_item:
		call_deferred("queue_free")


func _on_course_correction_timer_timeout() -> void:
	_set_direction_to_nearest_non_maxed_score_item()
