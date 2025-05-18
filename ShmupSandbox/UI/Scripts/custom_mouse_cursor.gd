class_name CustomMouseCursor extends CanvasLayer

@onready var custom_cursor : AnimatedSprite2D = $mouse_sprite

@export var y_offset : float = 35.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(_delta: float) -> void:
	var mouse_x : float = get_viewport().get_mouse_position().x
	var mouse_y : float = get_viewport().get_mouse_position().y
	custom_cursor.position = Vector2(mouse_x, mouse_y + y_offset) #To line up mouse cursor with fingers