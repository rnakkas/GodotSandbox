class_name PickupPowerup extends Node2D

@onready var powerup_switch_timer : Timer = $powerup_switch_timer
@onready var sprite_fx : AnimatedSprite2D = %sprite_fx
@onready var sprite_od: AnimatedSprite2D = %sprite_od
@onready var sprite_ch : AnimatedSprite2D = %sprite_ch
@onready var sprite_fz : AnimatedSprite2D = %sprite_fz
@onready var powerup_label : Label = %powerup_label
@onready var collider_area : Area2D = %powerup_area

@onready var sprites_container : PathFollow2D = %pathfollow

@export var speed : float = 20
@export var powerup_switch_time : float = 5.5
@export var powerup_score : int = 1000 # Player gets score if current powerup level is maxed out

const idle_anim : String = "idle"
const collect_anim : String = "collect"

var powerups_array : Array = []
var current_powerup : int
var current_powerup_sprite : AnimatedSprite2D

var viewport_size : Vector2
var sprites_list : Array[AnimatedSprite2D] = []

## TODO: Update movement logic
	# Initial spawn: use similar logic to score item:
		# - explode towards center of screen
	# Get rid of path, make it an area2d
	# Move vertically up and down the screen within y bounds
	# Move horizontally from right to left

################################################
#NOTE: Ready
################################################
func _ready() -> void:
	viewport_size = get_viewport_rect().size
	powerup_label.visible = false

	powerups_array = GameManager.powerups.values().slice(1, GameManager.powerups.size())	# Ignore the "None" index in that enum
	
	Helper.set_timer_properties(powerup_switch_timer, false, powerup_switch_time)
	powerup_switch_timer.start()

	_create_sprites_list()
	_random_powerup_on_spawn()

## Create the array of powerups, ignore the fx sprite
func _create_sprites_list() -> void:
	for node : Node in sprites_container.get_children():
		if node is AnimatedSprite2D && node != sprite_fx:
			sprites_list.append(node)

## Show a random powerup on spawn
func _random_powerup_on_spawn() -> void:
	current_powerup = powerups_array.pick_random()
	_toggle_powerup_sprite()

## Toggle on the selected sprite
func _toggle_powerup_sprite() -> void:
	# var sprite : AnimatedSprite2D
	match current_powerup:
		1: # Overdrive
			current_powerup_sprite = sprite_od
		2: # Chorus
			current_powerup_sprite = sprite_ch
		3: # Fuzz
			current_powerup_sprite = sprite_fz
	
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
	for powerup : int in range(powerups_array.size()):
		if current_powerup == powerups_array[powerup]:
			powerup = (powerup + 1)%powerups_array.size()
			current_powerup = powerups_array[powerup]
			break

	_toggle_powerup_sprite()


################################################
#NOTE: Despawn when exiting screen left
################################################
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


################################################
#NOTE: Logic for when powerup is collected by player
################################################
func _on_powerup_area_body_entered(body:Node2D) -> void:
	if body is PlayerCat:
		## Disable collider area on collection
		collider_area.set_deferred("monitorable", false)
		collider_area.set_deferred("monitoring", false)

		## Stop the path follow movement on collection
		sprites_container.pathfollow_speed = 0.0

		## Turn off powerup switch timer
		powerup_switch_timer.stop()

		## Play collect animations
		_play_collect_anims_for_sprites()
		_set_label_properties()
		var tween : Tween = _play_collect_anims_for_label()

		## Send a global signal with the powerup type
		SignalsBus.powerup_collected_event.emit(current_powerup, powerup_score)

		## Finally despawn the powerup
		await current_powerup_sprite.animation_finished
		await tween.finished
		call_deferred("queue_free")

func _play_collect_anims_for_sprites() -> void:
	current_powerup_sprite.play(collect_anim)
	sprite_fx.play(collect_anim)

func _set_label_properties() -> void:
	var powerup_maxed : bool = (GameManager.powerup_max_reached && GameManager.current_powerup == current_powerup)
	var bombs_maxed : bool = (GameManager.player_bombs == GameManager.player_max_bombs && current_powerup == GameManager.powerups.Fuzz)
	
	var show_score : bool = powerup_maxed || bombs_maxed

	# Show score if powerup or bomb maxed conditions met, else display powerup text
	# Ternary condition: trurhy_value if condition else falsy_value
	powerup_label.text = str(powerup_score) if show_score else GameManager.powerups.find_key(current_powerup)
	
	powerup_label.visible = true

func _play_collect_anims_for_label() -> Tween:
	## Tween the label when powerup collected
	var tween = get_tree().create_tween()
	var final_position : Vector2 = Vector2(powerup_label.position.x, powerup_label.position.y - 35.0)
	
	tween.set_parallel(true)

	match current_powerup:
		1: # Overdrive
			tween.tween_property(powerup_label, "self_modulate", UiUtility.color_yellow, 0.3) # Fade to color of powerup
		2: # Chorus
			tween.tween_property(powerup_label, "self_modulate", UiUtility.color_blue, 0.3) # Fade to color of powerup
		3: # Fuzz
			tween.tween_property(powerup_label, "self_modulate", UiUtility.color_white, 0.3) # Fade to color of powerup
	
	tween.tween_property(powerup_label, "position", final_position, 0.3)
	
	tween.set_parallel(false)

	tween.tween_property(powerup_label, "self_modulate", UiUtility.color_transparent, 0.7) # Fade out effect

	return tween
