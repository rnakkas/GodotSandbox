class_name Helper extends Object

################################################
# Helper function class:
	# Holds all common helper functions
################################################

################################################
# Limit movement to screen bounds
################################################
static func clamp_movement_to_screen_bounds(viewport_size: Vector2, position: Vector2, x_clamp: bool, y_clamp: bool) -> Vector2:
	# Clamp position within bounds
	var max_bounds: Vector2 = viewport_size

	if x_clamp:
		position.x = clamp(
			position.x,
			GameManager.offset_x - GameManager.min_bounds.x,
			max_bounds.x - GameManager.offset_x
			)
	
	if y_clamp:
		position.y = clamp(
			position.y,
			GameManager.offset_y_screen_top + GameManager.min_bounds.y,
			max_bounds.y - GameManager.offset_y_screen_bottom
			)

	return position


################################################
# Switch y direction on hitting screen bounds
################################################
static func change_direction_on_hitting_screen_bounds(viewport_size, position, direction: Vector2) -> Vector2:
	if position.y <= GameManager.offset_y_screen_top:
		direction = Vector2.DOWN
	elif position.y >= viewport_size.y - GameManager.offset_y_screen_bottom:
		direction = Vector2.UP
	
	return direction


################################################
# Setting timer properties
################################################
static func set_timer_properties(timer: Timer, one_shot: bool, wait_time: float) -> void:
	timer.one_shot = one_shot
	timer.wait_time = wait_time


################################################
# Setting direction with arguments
################################################
static func set_direction(viewport_size: Vector2, origin: Vector2, target: Vector2 = Vector2.ZERO, random: bool = true) -> Vector2:
	if random:
		var rand_x: float = randf_range(0, viewport_size.x)
		var rand_y: float = randf_range(0, viewport_size.y)
		target = Vector2(rand_x, rand_y)
	
	var direction: Vector2 = origin.direction_to(target)
	
	return direction


################################################
# Get path using name
################################################
static func get_path_using_name(path_name: String) -> Path2D:
	var enemy_path: Path2D
	
	if GameManager.enemy_paths_list.size() == 0:
		return
	
	for path: Path2D in GameManager.enemy_paths_list:
		if path.name == path_name:
			enemy_path = path
			break
	return enemy_path