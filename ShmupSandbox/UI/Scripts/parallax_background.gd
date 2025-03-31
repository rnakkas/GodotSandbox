extends ParallaxBackground

@onready var background_layer : ParallaxLayer = $ParallaxLayer

@export var scroll_speed : float = 50.0 

func _process(delta: float) -> void:
	background_layer.motion_offset.y += scroll_speed * delta
