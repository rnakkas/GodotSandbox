class_name game extends Node2D

## Player
@onready var player : CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_ship_player_shooting(bullet_scene: PackedScene, locations: Array[Vector2]) -> void:
	for i:int in range(locations.size()):
		var bullet := bullet_scene.instantiate()
		bullet.position = locations[i]
		add_child(bullet)
