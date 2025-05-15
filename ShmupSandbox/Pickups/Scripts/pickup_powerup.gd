class_name PickupPowerup extends Node2D

@export var speed : float = 20

var viewport_size : Vector2

func _ready() -> void:
	viewport_size = get_viewport_rect().size

func _physics_process(delta: float) -> void:
	global_position.x -= speed * delta

func _process(_delta: float) -> void:
	_clamp_movement_to_screen_bounds()

func _clamp_movement_to_screen_bounds() -> void:
	# Clamp position within bounds
	var min_bounds : Vector2 = Vector2(0, 0)
	var max_bounds : Vector2 = viewport_size
	var offset_y_screen_bottom : float = 50.0
	var offset_y_screen_top : float = 50.0
	
	position.y = clamp(position.y, offset_y_screen_top + min_bounds.y, max_bounds.y - offset_y_screen_bottom)