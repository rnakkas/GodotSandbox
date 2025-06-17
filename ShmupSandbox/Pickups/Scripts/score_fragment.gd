class_name ScoreFragment extends Area2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var course_correction_timer : Timer = $course_correction_timer

@export var speed : float = 650.0
@export var course_correction_time : float = 0.3

var score_items_list : Array[Node] = []
var direction : Vector2
var nearest_score_item : Area2D

func _ready() -> void:
	_get_nearest_score_item()
	_set_direction_to_nearest_score_item()
	_set_timer_properties()
	sprite.play("fly")


func _get_nearest_score_item() -> void:
	var distance_to_score_item : float
	var score_item_distances_list : Array[float] = []
	var score_item_and_distance_map : Dictionary[Node, float] = {}

	for score_item : Node in score_items_list:
		if score_item is Area2D:
			distance_to_score_item = self.global_position.distance_to(score_item.global_position)
			score_item_distances_list.append(distance_to_score_item)
			score_item_and_distance_map[score_item] = distance_to_score_item

	score_item_distances_list.sort()

	print_debug("item distances list: ", score_item_distances_list, "\n")
	print_debug("item and distance map : ", score_item_and_distance_map, "\n")
	print_debug("nearest item's distance : ", score_item_distances_list[0], "\n")
	
	for item : Node in score_item_and_distance_map.keys():
		if score_item_and_distance_map[item] == score_item_distances_list[0]:
			nearest_score_item = item as Area2D
			print_debug("nearest item: ", nearest_score_item)
			break


func _set_direction_to_nearest_score_item() -> void:
	if nearest_score_item == null:
		return
	direction = self.global_position.direction_to(nearest_score_item.global_position)


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
