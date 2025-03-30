class_name player_ship extends CharacterBody2D

## Velocity
@export var _max_speed : float
@export var _acceleration : float
@export var _damping : float

## Shooting
@export var fire_rate : float

## Sprites
@onready var body: AnimatedSprite2D = %Body
@onready var thrusterL : AnimatedSprite2D = %ThrusterL
@onready var thrusterR : AnimatedSprite2D = %ThrusterR
@onready var muzzle_flash_l: AnimatedSprite2D = %MuzzleFlashL
@onready var muzzle_flash_r: AnimatedSprite2D = %MuzzleFlashR

## Muzzle
@onready var muzzle_l : Marker2D = %MuzzleL
@onready var muzzle_r : Marker2D = %MuzzleR

## Hurtbox
@onready var hurtbox : Area2D = $hurtbox

## Custom signals
signal shooting(bullet_scene:PackedScene, locations:Array[Vector2])

## Packed scenes
var bullet_scene : PackedScene = preload("res://ShmupSandbox/Player/Scenes/player_bullet.tscn")

var viewport_size : Vector2
var on_shooting_cooldown : bool
var is_dead : bool

func _ready() -> void:
	body.play("idle")
	thrusterL.play("idle")
	thrusterR.play("idle")
	muzzle_flash_l.play("idle")
	muzzle_flash_r.play("idle")
	
	viewport_size = get_viewport_rect().size

func handle_input(delta) -> void:
	var input_dir := Vector2.ZERO
	
	# Get input direction
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	input_dir = input_dir.normalized()  # Normalize for diagonal movement
	
	# Acceleration
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * _max_speed, _acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, _damping * delta)

func clamp_movement_to_screen_bounds() -> void:
	# Clamp position within bounds
	var min_bounds : Vector2 = Vector2(0, 0)
	var max_bounds : Vector2 = viewport_size
	var offset : float = 20.0
	
	position.x = clamp(position.x, offset - min_bounds.x, max_bounds.x - offset)
	position.y = clamp(position.y, offset - min_bounds.y, max_bounds.y - offset)

func handle_shooting() -> void:
	if Input.is_action_pressed("shoot"):
		if !on_shooting_cooldown:
			on_shooting_cooldown = true
			
			var locations : Array[Vector2] = [muzzle_l.global_position, muzzle_r.global_position]
			shooting.emit(bullet_scene, locations)
			
			muzzle_flash_l.play("shoot")
			muzzle_flash_r.play("shoot")
			
			await get_tree().create_timer(1/fire_rate).timeout
			on_shooting_cooldown = false

func _physics_process(delta):
	if (!is_dead):
		handle_input(delta)
		move_and_slide()

func _process(_delta: float) -> void:
	clamp_movement_to_screen_bounds()
	
	if (!is_dead):
		handle_shooting()

## Hit by enemy or enemy projectiles
func _on_hurtbox_area_entered(_area: Area2D) -> void:
	is_dead = true
	
	velocity = Vector2.ZERO
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	thrusterL.play("death")
	thrusterR.play("death")
	body.play("death")
	await body.animation_finished
	queue_free()
	
