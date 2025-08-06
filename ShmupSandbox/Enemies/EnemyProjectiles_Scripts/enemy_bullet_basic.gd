class_name EnemyBulletBasic extends Area2D

@onready var sprite: AnimatedSprite2D = $sprite
@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

@export var speed: float = 325.0 # Change per enenmy

var direction: Vector2 = Vector2.LEFT # Default direction
var angle_deg: float = 180.0 # Default angle, points to the left

## TODO: 
	# Spritesheet
	# Animations

func _ready() -> void:
	_connect_to_own_signals()
	_set_collision_layer_and_mask()
	direction = - direction.rotated(deg_to_rad(angle_deg)) # Since its facing the left
	self.rotate(deg_to_rad(angle_deg))


func _connect_to_own_signals() -> void:
	area_entered.connect(self._on_area_entered)
	body_entered.connect(self._on_body_entered)
	screen_notifier.screen_exited.connect(self._on_screen_notifier_screen_exited)
	

func _set_collision_layer_and_mask() -> void:
	collision_layer = 16 # Layer name: enemy_bullet
	collision_mask = 1 + 64 + 256 # Mask names: player, player_bomb, score_bullet_clear_area


func _physics_process(delta: float) -> void:
	global_position += speed * delta * direction


func _on_screen_notifier_screen_exited() -> void:
	call_deferred("queue_free")


func _on_area_entered(_area: Area2D) -> void:
	call_deferred("queue_free")


func _on_body_entered(body: Node2D) -> void:
	if body is PlayerCat:
		if body.is_dead:
			return
		call_deferred("queue_free")
