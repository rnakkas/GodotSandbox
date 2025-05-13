class_name SimpleCrtFilter extends CanvasLayer

func _ready() -> void:
	if GameManager.crt_filter:
		self.visible = true
	else:
		self.visible = false