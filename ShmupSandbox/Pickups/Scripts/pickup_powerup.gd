class_name PickupPowerup extends Node2D

@onready var powerup_switch_timer : Timer = $powerup_switch_timer
@onready var sprite_fx : AnimatedSprite2D = %sprite_fx

@onready var sprites_container : PathFollow2D = %pathfollow

@export var speed : float = 20
@export var powerup_switch_time : float = 5.5

var current_powerup : AnimatedSprite2D

var viewport_size : Vector2
var sprites_list : Array[AnimatedSprite2D] = []


################################################
#NOTE: Ready
################################################
func _ready() -> void:
	viewport_size = get_viewport_rect().size
	_set_timer_properties()
	_create_sprites_list()
	current_powerup = sprites_list.pick_random()

## Set timer properties
func _set_timer_properties() -> void:
	powerup_switch_timer.one_shot = false
	powerup_switch_timer.wait_time = powerup_switch_time
	powerup_switch_timer.start()


## Create the array of powerups, ignore the fx sprite
func _create_sprites_list() -> void:
	for node : Node in sprites_container.get_children():
		if node is AnimatedSprite2D && node != sprite_fx:
			sprites_list.append(node)


################################################
#NOTE: Physics process
################################################
func _physics_process(delta: float) -> void:
	global_position.x -= speed * delta


################################################
#NOTE: Process
################################################
func _process(_delta: float) -> void:
	_clamp_movement_to_screen_bounds()

func _clamp_movement_to_screen_bounds() -> void:
	# Clamp position within bounds
	var min_bounds : Vector2 = Vector2(0, 0)
	var max_bounds : Vector2 = viewport_size
	var offset_y_screen_bottom : float = 50.0
	var offset_y_screen_top : float = 50.0
	
	position.y = clamp(position.y, offset_y_screen_top + min_bounds.y, max_bounds.y - offset_y_screen_bottom)


################################################
#NOTE: Powerup switching timer signal connection
################################################
func _on_powerup_switch_timer_timeout() -> void:
	_switch_powerup()

# Iterate through the powerups array and switch to the next powerup in the array
func _switch_powerup() -> void:
	for powerup : int in range(sprites_list.size()):
		if sprites_list[powerup] == current_powerup:
			sprites_list[powerup].visible = false
			sprites_list[powerup].stop()

			powerup = (powerup + 1)%sprites_list.size()

			sprites_list[powerup].visible = true
			sprites_list[powerup].play("idle")

			current_powerup = sprites_list[powerup]
			break


################################################
#NOTE: Despawn when exiting screen left
################################################
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
