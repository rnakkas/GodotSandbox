class_name Helper extends Object

################################################
# NOTE: Helpfer function class:
    # Holds all common helper functions
################################################

################################################
# NOTE: Limit movement to screen bounds
################################################
static func clamp_movement_to_screen_bounds(viewport_size : Vector2, position : Vector2) -> Vector2:
    # Clamp position within bounds
    const min_bounds : Vector2 = Vector2(0, 0)
    var max_bounds : Vector2 = viewport_size
    const offset_x : float = 60.0
    const offset_y_screen_bottom : float = 60.0
    const offset_y_screen_top : float = 100.0

    position.x = clamp(position.x, offset_x - min_bounds.x, max_bounds.x - offset_x)
    position.y = clamp(position.y, offset_y_screen_top + min_bounds.y, max_bounds.y - offset_y_screen_bottom)

    return position
