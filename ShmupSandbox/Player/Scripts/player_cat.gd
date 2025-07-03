class_name PlayerCat extends CharacterBody2D

## Velocity
@export var _max_speed : float = 450.0

## Shooting handler
@onready var shooting_handler : ShootingHandler = $shooting_handler

## Bomb handler
@onready var bomb_handler : BombHandler = $bomb_handler

## Sprites
@onready var body: AnimatedSprite2D = %body
@onready var rocket : AnimatedSprite2D = %rocket
@onready var thruster : AnimatedSprite2D = %thruster
@onready var base_muzzle_flash: AnimatedSprite2D = %base_muzzle_flash
@onready var od_muzzle_flash : AnimatedSprite2D = %od_muzzle_flash
@onready var ch_muzzle_flash : AnimatedSprite2D = %ch_muzzle_flash
@onready var ch_muzzle_flash_1 : AnimatedSprite2D = %ch_muzzle_flash_1
@onready var ch_muzzle_flash_2 : AnimatedSprite2D = %ch_muzzle_flash_2
@onready var death : AnimatedSprite2D = %death
@onready var invincible : AnimatedSprite2D = %invincible

## Hurtbox
@onready var hurtbox : Area2D = $hurtbox

## Timers
@export var invincibility_time : float = 2.0
@onready var invincibility_timer : Timer = $invincibility_timer

## Damage
@export var damage : int = 25

var viewport_size : Vector2
var is_dead : bool
var can_be_invincible : bool


################################################
# NOTE: Ready
################################################
func _ready() -> void:
	viewport_size = get_viewport_rect().size
	invincibility_timer.wait_time = invincibility_time


################################################
# NOTE: Physics process
################################################
func _physics_process(_delta) -> void:
	if is_dead:
		return
	_handle_movement()
	move_and_slide()

func _handle_movement() -> void:
	var input_dir := Vector2.ZERO
	
	# Get input direction
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	input_dir = input_dir.normalized()  # Normalize for diagonal movement
	
	# Velocity calcs
	if input_dir != Vector2.ZERO:
		velocity = input_dir * _max_speed
	else:
		velocity = Vector2.ZERO

################################################
# NOTE: Process
################################################
func _process(_delta: float) -> void:
	position = Helper.clamp_movement_to_screen_bounds(viewport_size, position, true, true)
	_handle_invincibility()

func _handle_invincibility() -> void:
	if can_be_invincible:
		can_be_invincible = false
		invincibility_timer.start()
		
		hurtbox.set_deferred("monitoring", false)
		hurtbox.set_deferred("monitorable", false)
		
		rocket.visible = false # Contains body and thruster sprites
		invincible.play("invincible")


################################################
# NOTE: Game pause handler
################################################
func _unhandled_input(event: InputEvent) -> void: 
	if event.is_action_pressed("pause"):
		SignalsBus.player_pressed_pause_game_event.emit()


################################################
# NOTE: Hurtbox signal
# Handle getting hit by enemies or projectiles
################################################
func _on_hurtbox_area_entered(_area: Area2D) -> void:
	# To prevent moving, shooting or bombing when dead
	is_dead = true
	shooting_handler.is_dead = true
	bomb_handler.is_dead = true
	
	velocity = Vector2.ZERO
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	
	rocket.visible = false # Contains body and thruster sprites
	death.play("death")

	SignalsBus.spawn_powerup_event.emit(self.global_position)	
	
	await death.animation_finished
	
	## wait 0.5 seconds before sending signal to player spawner
	await get_tree().create_timer(0.5).timeout 
	
	SignalsBus.player_death_event.emit()
	
	queue_free()
	

################################################
# NOTE: Stop invincibility signal
################################################
func _on_invincibility_timer_timeout() -> void:
	# Re-enable hurtbox
	hurtbox.set_deferred("monitoring", true)
	hurtbox.set_deferred("monitorable", true)
	
	# Return to default animations
	rocket.visible = true # Contains body and thruster sprites
	invincible.play("none")


################################################
#NOTE: Handle shooting signals, used for animations
################################################
func _on_shooting_handler_now_shooting(powerup : GameManager.powerups, level : int) -> void:
	if is_dead:
		return
	body.play("shoot")

	match powerup:
		GameManager.powerups.None:
			base_muzzle_flash.play("shoot")
		GameManager.powerups.Overdrive:
			od_muzzle_flash.play("shoot")
		GameManager.powerups.Chorus:
			ch_muzzle_flash.play("shoot")
			if level == 4:
				ch_muzzle_flash_1.play("shoot")
				ch_muzzle_flash_2.play("shoot")


func _on_shooting_handler_stopped_shooting() -> void:
	base_muzzle_flash.play("none")
	od_muzzle_flash.play("none")
	ch_muzzle_flash.play("none")
	ch_muzzle_flash_1.play("none")
	ch_muzzle_flash_2.play("none")
	body.play("idle")
	body.frame = rocket.frame
	