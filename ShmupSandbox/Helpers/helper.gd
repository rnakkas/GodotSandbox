class_name Helper extends Object

################################################
# NOTE: Helpfer function class:
    # Holds all common helper functions
################################################

################################################
# NOTE: Limit movement to screen bounds
################################################
static func clamp_movement_to_screen_bounds(
                                            viewport_size : Vector2, 
                                            position : Vector2, 
                                            x_clamp : bool, 
                                            y_clamp : bool
                                            ) -> Vector2:
    # Clamp position within bounds
    const min_bounds : Vector2 = Vector2(0, 0)
    var max_bounds : Vector2 = viewport_size
    const offset_x : float = 60.0
    const offset_y_screen_bottom : float = 60.0
    const offset_y_screen_top : float = 100.0

    if x_clamp:
        position.x = clamp(position.x, offset_x - min_bounds.x, max_bounds.x - offset_x)
    
    if y_clamp:
        position.y = clamp(position.y, offset_y_screen_top + min_bounds.y, max_bounds.y - offset_y_screen_bottom)

    return position


################################################
# NOTE: Setting timer properties
################################################
static func set_timer_properties(timer : Timer, one_shot : bool, wait_time: float) -> void:
    timer.one_shot = one_shot
    timer.wait_time = wait_time