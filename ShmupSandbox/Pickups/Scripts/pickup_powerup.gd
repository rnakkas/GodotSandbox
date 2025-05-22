class_name PickupPowerup extends Node2D

@onready var powerup_switch_timer : Timer = $powerup_switch_timer
@onready var sprite_fx : AnimatedSprite2D = %sprite_fx
@onready var sprite_od: AnimatedSprite2D = %sprite_od
@onready var sprite_ch : AnimatedSprite2D = %sprite_ch
@onready var powerup_label : Label = %powerup_label

@onready var sprites_container : PathFollow2D = %pathfollow

@export var speed : float = 20
@export var powerup_switch_time : float = 5.5

const idle_anim : String = "idle"
const collect_anim : String = "collect"

var current_powerup : int
var current_powerup_sprite : AnimatedSprite2D

var viewport_size : Vector2
var sprites_list : Array[AnimatedSprite2D] = []


################################################
#NOTE: Ready
################################################
func _ready() -> void:
	viewport_size = get_viewport_rect().size
	powerup_label.visible = false
	
	_set_timer_properties()
	_create_sprites_list()
	_random_powerup_on_spawn()
	
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

## Show a random powerup on spawn
func _random_powerup_on_spawn() -> void:
	current_powerup = GameManager.powerups.values().pick_random()
	_toggle_powerup_sprite()

## Toggle on the selected sprite
func _toggle_powerup_sprite() -> void:
	# var sprite : AnimatedSprite2D
	match current_powerup:
		0:
			current_powerup_sprite = sprite_od
		1:
			current_powerup_sprite = sprite_ch
	
	for powerup_sprite : AnimatedSprite2D in sprites_list:
		if powerup_sprite == current_powerup_sprite:
			powerup_sprite.visible = true
			powerup_sprite.play(idle_anim)
		else:
			powerup_sprite.visible = false
			powerup_sprite.stop()

################################################
#NOTE: Physics process
################################################
func _physics_process(delta: float) -> void:
	global_position.x -= speed * delta


################################################
#NOTE: Process
################################################
func _process(_delta: float) -> void:
	_clamp_movement_to_screen_y_bounds()

func _clamp_movement_to_screen_y_bounds() -> void:
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

# Iterate through the powerups array and switch to a random powerup from the list
func _switch_powerup() -> void:
	for powerup : int in range(GameManager.powerups.values().size()):
		if current_powerup == GameManager.powerups.values()[powerup]:
			powerup = (powerup + 1)%GameManager.powerups.values().size()
			current_powerup = GameManager.powerups.values()[powerup]
			break

	_toggle_powerup_sprite()


################################################
#NOTE: Despawn when exiting screen left
################################################
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_powerup_area_body_entered(body:Node2D) -> void:
	if body is PlayerCat:
		print("player picked up item: ", GameManager.powerups.find_key(current_powerup))

		## Labels
		powerup_label.text = GameManager.powerups.find_key(current_powerup)
		powerup_label.visible = true
		
		## Stop the path follow movement on collection
		sprites_container.pathfollow_speed = 0.0

		## Turn off powerup switch timer
		powerup_switch_timer.stop()

		## Play collect animation
		current_powerup_sprite.play(collect_anim)
		sprite_fx.play(collect_anim)

		## TODO: Tween the label when powerup collected
		var final_position : Vector2 = Vector2(powerup_label.position.x, powerup_label.position.y - 30.0)

		var tween = get_tree().create_tween()
		
		tween.set_parallel(true)
		match current_powerup:
			0: # Overdrive
				tween.tween_property(powerup_label, "self_modulate", UiUtility.color_yellow, 0.3) # Fade to color of powerup
			1: # Chorus
				tween.tween_property(powerup_label, "self_modulate", UiUtility.color_blue, 0.3) # Fade to color of powerup
		tween.tween_property(powerup_label, "position", final_position, 0.3)
		
		tween.set_parallel(false)
		tween.tween_property(powerup_label, "self_modulate", UiUtility.color_transparent, 1) # Fade out effect

		## TODO: Send a global signal with the powerup type
		## TODO: Then call deferred to queue_free() the powerup
