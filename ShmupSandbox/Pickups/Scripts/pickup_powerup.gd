class_name PickupPowerup extends Area2D

@onready var powerup_switch_timer: Timer = $powerup_switch_timer
@onready var move_timer: Timer = $move_timer
@onready var sprite_fx: AnimatedSprite2D = %sprite_fx
@onready var sprite_od: AnimatedSprite2D = %sprite_od
@onready var sprite_ch: AnimatedSprite2D = %sprite_ch
@onready var sprite_fz: AnimatedSprite2D = %sprite_fz
@onready var powerup_label: Label = %powerup_label

@export var base_speed_x: float = 7.5
@export var base_speed_y: float = 50
@export var spawn_speed: float = 500.0
@export var deceleration: float = 1000.0
@export var powerup_switch_time: float = 5.5
@export var move_time: float = 0.1
@export var powerup_score: int = 1000 # Player gets score if current powerup level is maxed out

const idle_anim: String = "idle"
const collect_anim: String = "collect"

var powerups_array: Array = []
var current_powerup: int
var current_powerup_sprite: AnimatedSprite2D

var viewport_size: Vector2
var sprites_list: Array[AnimatedSprite2D] = []

var direction: Vector2
var velocity: Vector2
var idle_state: bool


################################################
#NOTE: Ready
################################################
func _ready() -> void:
	# Get viewport size
	viewport_size = get_viewport_rect().size
	
	# Set powerup label to be invisible
	powerup_label.visible = false

	# Create poowerups list/array
	powerups_array = GameManager.powerups.values().slice(1, GameManager.powerups.size()) # Ignore the "None" index in that enum
	
	# Set timer properties and start timers
	Helper.set_timer_properties(powerup_switch_timer, false, powerup_switch_time)
	Helper.set_timer_properties(move_timer, true, move_time)
	powerup_switch_timer.start()
	move_timer.start()

	# Create list of sprites
	_create_sprites_list()

	# Select a random powerup to be active on spawn
	_random_powerup_on_spawn()

	# Set initial spawn movement direction
	var screen_ceter: Vector2 = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	direction = Helper.set_direction(viewport_size, self.global_position, screen_ceter, false)
	
	# Set spawn velocity
	velocity = spawn_speed * direction


## Create the array of powerups, ignore the fx sprite
func _create_sprites_list() -> void:
	for node: Node in get_children():
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
	
	for powerup_sprite: AnimatedSprite2D in sprites_list:
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
	if idle_state:
		# Movement when in idle state
		# Move slowly from right to left while moving up and down the screen
		var vel_x: float = base_speed_x * Vector2.LEFT.x
		var vel_y: float = base_speed_y * direction.y
		var vel: Vector2 = Vector2(vel_x, vel_y)
		velocity = velocity.move_toward(vel, deceleration * delta)
	
	global_position += velocity * delta


################################################
#NOTE: Process
################################################
func _process(_delta: float) -> void:
	position = Helper.clamp_movement_to_screen_bounds(viewport_size, position, false, true)

	# Switch y direction if hitting upper or lower screen bounds
	direction = Helper.change_direction_on_hitting_screen_bounds(viewport_size, position, direction)

################################################
#NOTE: Powerup switching timer signal connection
################################################
func _on_powerup_switch_timer_timeout() -> void:
	_switch_powerup()

# Iterate through the powerups array and switch to a random powerup from the list
func _switch_powerup() -> void:
	for powerup: int in range(powerups_array.size()):
		if current_powerup == powerups_array[powerup]:
			powerup = (powerup + 1)%powerups_array.size()
			current_powerup = powerups_array[powerup]
			break

	_toggle_powerup_sprite()


################################################
#NOTE: Despawn after exiting screen
################################################
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	call_deferred("queue_free")


################################################
#NOTE: Logic for when powerup is collected by player
################################################
func _on_body_entered(body: Node2D) -> void:
	if body is PlayerCat:
		## Do nothing if the player is dead
		if body.is_dead:
			return
		
		## Disable collider area on collection
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)

		## Stop on collection
		direction = Vector2.ZERO

		## Turn off powerup switch timer
		powerup_switch_timer.stop()

		## Play collect animations
		_play_collect_anims_for_sprites()
		_set_label_properties()
		var tween: Tween = _play_collect_anims_for_label()

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
	var powerup_maxed: bool = (GameManager.powerup_max_reached && GameManager.current_powerup == current_powerup)
	var bombs_maxed: bool = (GameManager.player_bombs == GameManager.player_max_bombs && current_powerup == GameManager.powerups.Fuzz)
	
	var show_score: bool = powerup_maxed || bombs_maxed

	# Show score if powerup or bomb maxed conditions met, else display powerup text
	# Ternary condition: trurhy_value if condition else falsy_value
	powerup_label.text = str(powerup_score) if show_score else GameManager.powerups.find_key(current_powerup)
	
	powerup_label.visible = true

func _play_collect_anims_for_label() -> Tween:
	## Tween the label when powerup collected
	var tween = get_tree().create_tween()
	var final_position: Vector2 = Vector2(powerup_label.position.x, powerup_label.position.y - 35.0)
	
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


################################################
#NOTE: Set to idle state after initial spawn explosion movement
################################################
func _on_move_timer_timeout() -> void:
	idle_state = true
	direction = Vector2.UP
